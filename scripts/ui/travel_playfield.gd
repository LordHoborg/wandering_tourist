class_name TravelPlayfield
extends Control

const Backdrop = preload("res://scripts/ui/tropical_backdrop.gd")

const LANE_TOP := 300.0
const LANE_HEIGHT := 680.0
const CUT_START := 850.0
const FLASH_DURATION := 0.35
var cut_ready: Array[bool] = [false, false]
var _flashes: Array[Dictionary] = []

func set_cut_ready(left_ready: bool, right_ready: bool) -> void:
	cut_ready = [left_ready, right_ready]
	queue_redraw()

## Brief expanding ring on a lane's action line after a resolution.
func flash_lane(lane: int, good: bool) -> void:
	_flashes.append({"lane": lane, "good": good, "at": Time.get_ticks_msec() / 1000.0})
	queue_redraw()

func _process(_delta: float) -> void:
	# Backdrop waves/clouds and the action-line pulse animate every frame.
	queue_redraw()

func _draw() -> void:
	var now := Time.get_ticks_msec() / 1000.0
	Backdrop.draw(self, size, now, AppSettings.reduced_motion)
	for lane in range(2):
		_draw_lane(lane, now)
	_draw_flashes(now)

func _draw_lane(lane: int, now: float) -> void:
	var x := 40.0 if lane == 0 else 380.0
	var ready: bool = cut_ready[lane]
	var panel := StyleBoxFlat.new()
	panel.bg_color = Color(0.03, 0.10, 0.22, 0.48)
	panel.border_color = Color(0.62, 0.93, 0.89, 0.75) if ready else Color(0.45, 0.78, 0.78, 0.45)
	panel.set_border_width_all(3 if ready else 2)
	panel.set_corner_radius_all(22)
	draw_style_box(panel, Rect2(x, LANE_TOP, 300, LANE_HEIGHT))
	# Soft fall track guiding the eye down the lane.
	var track := StyleBoxFlat.new()
	track.bg_color = Color(1, 1, 1, 0.045)
	track.set_corner_radius_all(14)
	draw_style_box(track, Rect2(x + 108, LANE_TOP + 18, 84, CUT_START - LANE_TOP - 30))
	# Cut window zone.
	var zone := StyleBoxFlat.new()
	var pulse := 1.0 if AppSettings.reduced_motion else 0.5 + 0.5 * sin(now * TAU * 1.4)
	zone.bg_color = Color(0.98, 0.72, 0.28, (0.16 + 0.14 * pulse) if ready else 0.09)
	zone.border_color = Color("ffe08a") if ready else Color(0.65, 0.85, 0.85, 0.35)
	zone.set_border_width_all(3 if ready else 2)
	zone.set_corner_radius_all(16)
	draw_style_box(zone, Rect2(x + 12, CUT_START, 276, 130))
	# Action line with a glow pass when armed.
	var line_color := Color("ffe08a") if ready else Color("8bbec5")
	if ready:
		draw_line(Vector2(x + 15, 922), Vector2(x + 285, 922), Color(1.0, 0.88, 0.54, 0.30 + 0.20 * pulse), 11.0)
	draw_line(Vector2(x + 15, 922), Vector2(x + 285, 922), line_color, 5.0)
	if ready:
		_draw_chevrons(x + 150, now)
		var alpha := 1.0 if AppSettings.reduced_motion else 0.65 + 0.35 * pulse
		draw_string(ThemeDB.fallback_font, Vector2(x + 96, 885), "TAP NOW", HORIZONTAL_ALIGNMENT_LEFT, -1, 21, Color(1.0, 0.95, 0.73, alpha))
	draw_string(ThemeDB.fallback_font, Vector2(x + 25, 960), "ACTION LINE", HORIZONTAL_ALIGNMENT_LEFT, -1, 15, Color("ffe9af"))

func _draw_chevrons(center_x: float, now: float) -> void:
	for index in 3:
		var drift := 0.0 if AppSettings.reduced_motion else fmod(now * 46.0 + index * 16.0, 48.0)
		var y := 862.0 + index * 16.0 + drift * 0.4
		var fade := 1.0 - index * 0.25
		var a := Vector2(center_x - 16, y)
		var b := Vector2(center_x, y + 9)
		var c := Vector2(center_x + 16, y)
		draw_line(a, b, Color(1.0, 0.90, 0.60, fade), 3.5)
		draw_line(b, c, Color(1.0, 0.90, 0.60, fade), 3.5)

func _draw_flashes(now: float) -> void:
	var alive: Array[Dictionary] = []
	for flash in _flashes:
		var age: float = now - flash["at"]
		if age >= FLASH_DURATION:
			continue
		alive.append(flash)
		var progress: float = age / FLASH_DURATION
		var x := 190.0 if flash["lane"] == 0 else 530.0
		var color := Color("ffe08a") if flash["good"] else Color("ff9b89")
		if AppSettings.reduced_motion:
			draw_circle(Vector2(x, 922), 46, Color(color, 0.35 * (1.0 - progress)))
		else:
			color.a = 0.85 * (1.0 - progress)
			draw_arc(Vector2(x, 922), 24.0 + progress * 84.0, 0, TAU, 32, color, 4.0)
	_flashes = alive
