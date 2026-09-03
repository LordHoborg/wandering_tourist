class_name AudioDirector
extends Node

## Procedural sound-effects director. All cues are synthesized at startup as
## 8-bit AudioStreamWAV tones, so the project needs no binary audio assets.
## Honors AppSettings.muted and AppSettings.sfx_volume at play time.

const MIX_RATE := 22050
const POOL_SIZE := 4
const AMBIENCE_SECONDS := 12.0
const AMBIENCE_VOLUME_SCALE := 0.45

## Each cue is a list of [frequency_hz, duration_seconds] notes played in
## sequence; zero frequency inserts silence.
const CUES: Dictionary = {
	&"cut_success": [[660.0, 0.07], [880.0, 0.10]],
	&"harmful_cut": [[220.0, 0.14], [160.0, 0.20]],
	&"hazard_passed": [[520.0, 0.09]],
	&"beneficial_missed": [[440.0, 0.09], [330.0, 0.14]],
	&"warning": [[880.0, 0.08], [0.0, 0.05], [880.0, 0.08]],
	&"stage_started": [[523.0, 0.10], [659.0, 0.10], [784.0, 0.16]],
	&"completed": [[523.0, 0.10], [659.0, 0.10], [784.0, 0.10], [1047.0, 0.24]],
	&"failed": [[392.0, 0.16], [311.0, 0.16], [233.0, 0.28]],
	&"spawn": [[980.0, 0.04]],
	&"ui_start": [[587.0, 0.08], [880.0, 0.12]],
	&"ui_pause": [[440.0, 0.06], [330.0, 0.08]],
	&"spirit_milestone": [[784.0, 0.07], [988.0, 0.07], [1175.0, 0.14]],
	&"cut_window_open": [[740.0, 0.05], [880.0, 0.08]],
}

var streams: Dictionary = {}
var settings: Node = null ## Injected by the composition root; falls back to the AppSettings autoload.
var ambience: AudioStreamPlayer = null
var _players: Array[AudioStreamPlayer] = []
var _next_player: int = 0

func _ready() -> void:
	_ensure_ready()

func _ensure_ready() -> void:
	# Lazy so the director also works when a host adds children at unusual
	# times (headless test rigs) where _ready ordering is not guaranteed.
	if streams.is_empty():
		for cue_id in CUES:
			streams[cue_id] = synthesize(CUES[cue_id])
	if _players.is_empty():
		# Safe outside the tree too: children enter the tree with this node.
		for i in POOL_SIZE:
			var player := AudioStreamPlayer.new()
			player.bus = &"Master"
			add_child(player)
			_players.append(player)
	if ambience == null:
		ambience = AudioStreamPlayer.new()
		ambience.stream = synthesize_ambience()
		add_child(ambience)
		if is_inside_tree():
			ambience.play()

func _process(_delta: float) -> void:
	if ambience == null:
		return
	if is_inside_tree() and not ambience.playing:
		ambience.play()
	var source: Node = settings if settings != null else get_node_or_null("/root/AppSettings")
	var muted: bool = source != null and bool(source.get("muted"))
	var volume: float = 1.0 if source == null else float(source.get("sfx_volume"))
	if muted or volume <= 0.0:
		ambience.volume_db = -80.0
	else:
		ambience.volume_db = linear_to_db(maxf(volume * AMBIENCE_VOLUME_SCALE, 0.001))

func has_cue(cue: StringName) -> bool:
	_ensure_ready()
	return streams.has(cue)

## Plays the cue if one exists and audio is enabled. Returns true when a cue
## actually started; unknown kinds and muted/zero-volume requests are inert.
func play_cue(cue: StringName) -> bool:
	_ensure_ready()
	if not streams.has(cue) or _players.is_empty():
		return false
	# Resolve settings at play time so this node also works in headless script
	# contexts where autoload globals are not registered.
	var source: Node = settings if settings != null else get_node_or_null("/root/AppSettings")
	var muted: bool = source != null and bool(source.get("muted"))
	var volume: float = 1.0 if source == null else float(source.get("sfx_volume"))
	if muted or volume <= 0.0:
		return false
	var player := _players[_next_player]
	_next_player = (_next_player + 1) % POOL_SIZE
	player.stream = streams[cue]
	player.volume_db = linear_to_db(maxf(volume, 0.001))
	if player.is_inside_tree():
		player.play()
	return true

## Builds a mono 8-bit WAV stream from a note sequence with a short linear
## attack and exponential release so cues do not click.
static func synthesize(notes: Array) -> AudioStreamWAV:
	var data := PackedByteArray()
	for note in notes:
		var frequency: float = note[0]
		var count := int(MIX_RATE * note[1])
		for i in count:
			var sample := 128
			if frequency > 0.0:
				var t := float(i) / MIX_RATE
				var envelope := minf(float(i) / (MIX_RATE * 0.01), 1.0) * exp(-3.0 * t / maxf(note[1], 0.01))
				sample = 128 + int(110.0 * envelope * sin(TAU * frequency * t))
			data.append(clampi(sample, 0, 255))
	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_8_BITS
	stream.mix_rate = MIX_RATE
	stream.data = data
	return stream

## Builds the looping background layer: low-passed deterministic noise as
## ocean surf with a slow swell, plus a sparse pentatonic pluck melody.
## Deterministic; both edges fade to silence for a click-free loop.
static func synthesize_ambience() -> AudioStreamWAV:
	var total := int(MIX_RATE * AMBIENCE_SECONDS)
	var buf := PackedFloat32Array()
	buf.resize(total)
	var last := 0.0
	for i in total:
		last = last * 0.982 + _hash_noise(i) * 0.018
		var swell := 0.55 + 0.45 * sin(TAU * (float(i) / MIX_RATE) / 6.0)
		buf[i] = last * swell
	var notes := [523.25, 587.33, 659.25, 783.99, 880.0]
	var pattern := [0, 2, 4, 3, 1, 2]
	var times := [0.6, 2.4, 4.2, 6.6, 8.4, 10.2]
	for n in times.size():
		var start := int(times[n] * MIX_RATE)
		var frequency: float = notes[pattern[n]]
		var duration := 1.3
		for i in int(duration * MIX_RATE):
			var index := start + i
			if index >= total:
				break
			var t := float(i) / MIX_RATE
			var envelope := exp(-3.5 * t / duration)
			buf[index] += 0.22 * envelope * (sin(TAU * frequency * t) + 0.35 * sin(TAU * frequency * 4.0 * t) * exp(-8.0 * t / duration))
	var peak := 0.01
	for i in total:
		peak = maxf(peak, absf(buf[i]))
	var data := PackedByteArray()
	data.resize(total)
	var fade := int(MIX_RATE * 0.25)
	for i in total:
		var sample: float = buf[i] / peak * 96.0
		if i < fade:
			sample *= float(i) / fade
		if i > total - fade:
			sample *= float(total - i) / fade
		data[i] = clampi(128 + int(sample), 0, 255)
	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_8_BITS
	stream.mix_rate = MIX_RATE
	stream.data = data
	stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
	stream.loop_begin = 0
	stream.loop_end = total
	return stream

static func _hash_noise(index: int) -> float:
	var s := sin(float(index) * 12.9898) * 43758.5453
	return (s - floor(s)) * 2.0 - 1.0
