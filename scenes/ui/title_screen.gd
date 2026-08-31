class_name TitleScreen
extends Control

## Vertical-slice entry point: title art, best score, and the settings UI
## (mute, SFX volume, reduced motion) required by the GDD. Emits
## start_requested; gameplay_root owns the actual run start.

signal start_requested

var best_score: int = 0

@onready var _mute_button: Button = $Buttons/MuteButton
@onready var _volume_button: Button = $Buttons/VolumeButton
@onready var _motion_button: Button = $Buttons/MotionButton

func _ready() -> void:
	$Buttons/StartButton.pressed.connect(func() -> void: start_requested.emit())
	_mute_button.pressed.connect(_on_mute_pressed)
	_volume_button.pressed.connect(_on_volume_pressed)
	_motion_button.pressed.connect(_on_motion_pressed)
	_refresh_settings_labels()

func set_best_score(value: int) -> void:
	best_score = value
	queue_redraw()

func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, size), Color("172a4d"))
	for band in range(12):
		var t := float(band) / 11.0
		draw_rect(Rect2(0, band * 110, size.x, 112), Color(0.12 + t * 0.58, 0.20 + t * 0.22, 0.42 + t * 0.08))
	draw_circle(Vector2(560, 330), 96, Color("ffd475")); draw_circle(Vector2(560, 330), 70, Color("ffe6a4"))
	var island := PackedVector2Array([Vector2(0, 700), Vector2(160, 610), Vector2(330, 690), Vector2(480, 600), Vector2(650, 690), Vector2(720, 640), Vector2(720, 1280), Vector2(0, 1280)])
	draw_colored_polygon(island, Color("17494c"))
	var font := ThemeDB.fallback_font
	draw_string(font, Vector2(90, 420), "WANDERING", HORIZONTAL_ALIGNMENT_CENTER, 540, 58, Color("fff0bd"))
	draw_string(font, Vector2(90, 490), "TOURIST", HORIZONTAL_ALIGNMENT_CENTER, 540, 58, Color("fff0bd"))
	draw_string(font, Vector2(90, 545), "Keep Hunger, Rest and Fun in the safe zone.", HORIZONTAL_ALIGNMENT_CENTER, 540, 18, Color("a8e5dc"))
	draw_string(font, Vector2(90, 640), "BEST SCORE  %d" % best_score, HORIZONTAL_ALIGNMENT_CENTER, 540, 22, Color("ffe08a"))

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
