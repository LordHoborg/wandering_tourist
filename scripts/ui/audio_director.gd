class_name AudioDirector
extends Node

## Procedural sound-effects director. All cues are synthesized at startup as
## soft 16-bit AudioStreamWAV tones, so the project needs no binary assets.
## Honors AppSettings.muted and AppSettings.sfx_volume at play time.

const MIX_RATE := 44100
const POOL_SIZE := 4
const AMBIENCE_SECONDS := 18.0
const AMBIENCE_VOLUME_SCALE := 0.18

## Each cue is a list of [frequency_hz, duration_seconds] notes played in
## sequence; zero frequency inserts silence.
const CUES: Dictionary = {
	&"cut_success": [[392.0, 0.08], [523.0, 0.12]],
	&"harmful_cut": [[196.0, 0.14], [147.0, 0.22]],
	&"hazard_passed": [[330.0, 0.10]],
	&"beneficial_missed": [[294.0, 0.10], [220.0, 0.16]],
	&"warning": [[440.0, 0.07], [0.0, 0.07], [440.0, 0.07]],
	&"stage_started": [[262.0, 0.12], [330.0, 0.12], [392.0, 0.18]],
	&"completed": [[262.0, 0.12], [330.0, 0.12], [392.0, 0.12], [523.0, 0.26]],
	&"failed": [[247.0, 0.18], [196.0, 0.18], [147.0, 0.30]],
	&"spawn": [[330.0, 0.035]],
	&"ui_start": [[294.0, 0.09], [392.0, 0.14]],
	&"ui_pause": [[262.0, 0.07], [196.0, 0.10]],
	&"spirit_milestone": [[392.0, 0.09], [494.0, 0.09], [587.0, 0.16]],
	&"cut_window_open": [[370.0, 0.05], [440.0, 0.09]],
	&"risky_combo": [[233.0, 0.10], [175.0, 0.18]],
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

## Builds a mono 16-bit WAV stream with smooth attack/release envelopes.
static func synthesize(notes: Array) -> AudioStreamWAV:
	var data := PackedByteArray()
	for note in notes:
		var frequency: float = note[0]
		var count := int(MIX_RATE * note[1])
		for i in count:
			var sample := 0.0
			if frequency > 0.0:
				var t := float(i) / MIX_RATE
				var attack := minf(float(i) / (MIX_RATE * 0.025), 1.0)
				var release := minf(float(count - i) / (MIX_RATE * 0.055), 1.0)
				var envelope := attack * release * exp(-1.8 * t / maxf(note[1], 0.01))
				sample = 0.26 * envelope * (sin(TAU * frequency * t) + 0.12 * sin(TAU * frequency * 2.0 * t))
			_append_sample_16(data, sample)
	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = MIX_RATE
	stream.data = data
	return stream

## Builds a subdued looping background layer: heavily smoothed ocean noise,
## low sine pads, and sparse low-register pentatonic notes.
## Deterministic; both edges fade to silence for a click-free loop.
static func synthesize_ambience() -> AudioStreamWAV:
	var total := int(MIX_RATE * AMBIENCE_SECONDS)
	var buf := PackedFloat32Array()
	buf.resize(total)
	var last := 0.0
	for i in total:
		last = last * 0.997 + _hash_noise(i) * 0.003
		var time := float(i) / MIX_RATE
		var swell := 0.45 + 0.22 * sin(TAU * time / 9.0)
		var pad := 0.07 * sin(TAU * 98.0 * time) + 0.045 * sin(TAU * 147.0 * time)
		buf[i] = last * swell * 0.24 + pad
	var notes := [196.0, 220.0, 247.0, 294.0, 330.0]
	var pattern := [0, 2, 4, 1, 3, 2]
	var times := [1.2, 4.0, 6.8, 9.8, 12.8, 15.4]
	for n in times.size():
		var start := int(times[n] * MIX_RATE)
		var frequency: float = notes[pattern[n]]
		var duration := 1.8
		for i in int(duration * MIX_RATE):
			var index := start + i
			if index >= total:
				break
			var t := float(i) / MIX_RATE
			var attack := minf(t / 0.08, 1.0)
			var envelope := attack * exp(-3.0 * t / duration)
			buf[index] += 0.10 * envelope * (sin(TAU * frequency * t) + 0.08 * sin(TAU * frequency * 2.0 * t))
	var data := PackedByteArray()
	var fade := int(MIX_RATE * 0.25)
	for i in total:
		var sample: float = tanh(buf[i] * 1.4) * 0.42
		if i < fade:
			sample *= float(i) / fade
		if i > total - fade:
			sample *= float(total - i) / fade
		_append_sample_16(data, sample)
	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = MIX_RATE
	stream.data = data
	stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
	stream.loop_begin = 0
	stream.loop_end = total
	return stream

static func _hash_noise(index: int) -> float:
	var s := sin(float(index) * 12.9898) * 43758.5453
	return (s - floor(s)) * 2.0 - 1.0

static func _append_sample_16(data: PackedByteArray, value: float) -> void:
	var signed_sample := clampi(int(clampf(value, -1.0, 1.0) * 32767.0), -32768, 32767)
	var encoded := signed_sample if signed_sample >= 0 else 65536 + signed_sample
	data.append(encoded & 0xff)
	data.append((encoded >> 8) & 0xff)
