class_name TitleScreen
extends Control

## Vertical-slice entry point: title art, best score, and the settings UI
## (mute, SFX volume, reduced motion) required by the GDD. Emits
## start_requested; gameplay_root owns the actual run start.

signal start_requested

const Backdrop = preload("res://scripts/ui/tropical_backdrop.gd")
const BACKDROP_FRAME_INTERVAL := 1.0 / 30.0

var best_score: int = 0
var _backdrop_elapsed := 0.0

@onready var _mute_button: Button = $Buttons/MuteButton
@onready var _volume_button: Button = $Buttons/VolumeButton
@onready var _motion_button: Button = $Buttons/MotionButton

func _ready() -> void:
	$Buttons/StartButton.pressed.connect(func() -> void: start_requested.emit())
	_mute_button.pressed.connect(_on_mute_pressed)
	_volume_button.pressed.connect(_on_volume_pressed)
	_motion_button.pressed.connect(_on_motion_pressed)
	_refresh_settings_labels()

func _process(delta: float) -> void:
	if AppSettings.reduced_motion:
		return
	_backdrop_elapsed += delta
	if _backdrop_elapsed >= BACKDROP_FRAME_INTERVAL:
		_backdrop_elapsed = fmod(_backdrop_elapsed, BACKDROP_FRAME_INTERVAL)
		queue_redraw()

func set_best_score(value: int) -> void:
	best_score = value
	queue_redraw()

func _draw() -> void:
	Backdrop.draw(self, size, Time.get_ticks_msec() / 1000.0, AppSettings.reduced_motion)
	var font := ThemeDB.fallback_font
	draw_string(font, Vector2(92, 373), "WANDERING", HORIZONTAL_ALIGNMENT_CENTER, 540, 58, Color(0.10, 0.16, 0.30, 0.55))
	draw_string(font, Vector2(92, 443), "TOURIST", HORIZONTAL_ALIGNMENT_CENTER, 540, 58, Color(0.10, 0.16, 0.30, 0.55))
	draw_string(font, Vector2(90, 370), "WANDERING", HORIZONTAL_ALIGNMENT_CENTER, 540, 58, Color("fff0bd"))
	draw_string(font, Vector2(90, 440), "TOURIST", HORIZONTAL_ALIGNMENT_CENTER, 540, 58, Color("fff0bd"))
	draw_string(font, Vector2(90, 500), "Keep Hunger, Rest and Fun in the safe zone.", HORIZONTAL_ALIGNMENT_CENTER, 540, 18, Color(0.08, 0.20, 0.32))
	draw_string(font, Vector2(90, 640), "BEST SCORE  %d" % best_score, HORIZONTAL_ALIGNMENT_CENTER, 540, 22, Color("6b4a1f"))

func _on_mute_pressed() -> void:
	AppSettings.set_muted(not AppSettings.muted)
	_refresh_settings_labels()

func _on_volume_pressed() -> void:
	var steps := [0.0, 0.25, 0.5, 0.75, 1.0]
	var index := 0
	var best_gap := INF
	for i in steps.size():
		var gap: float = absf(steps[i] - AppSettings.sfx_volume)
		if gap < best_gap:
			best_gap = gap
			index = i
	AppSettings.set_sfx_volume(steps[(index + 1) % steps.size()])
	_refresh_settings_labels()

func _on_motion_pressed() -> void:
	AppSettings.set_reduced_motion(not AppSettings.reduced_motion)
	_refresh_settings_labels()

func _refresh_settings_labels() -> void:
	_mute_button.text = "SOUND: OFF" if AppSettings.muted else "SOUND: ON"
	_volume_button.text = "VOLUME: %d%%" % int(round(AppSettings.sfx_volume * 100.0))
	_motion_button.text = "REDUCED MOTION: ON" if AppSettings.reduced_motion else "REDUCED MOTION: OFF"
