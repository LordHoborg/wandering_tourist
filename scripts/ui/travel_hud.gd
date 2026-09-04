class_name TravelHud
extends Control

const WarningMonitor = preload("res://scripts/ui/warning_monitor.gd")
const TOTAL_STAGES := 15
const PARAMETER_SPECS := [
	[&"hunger", "H", "HUNGER", Color("ffb35c")],
	[&"rest", "Z", "REST", Color("91b9ff")],
	[&"fun", "*", "FUN", Color("f49ad6")],
	[&"social", "S", "SOCIAL", Color("a88cff")],
	[&"hygiene", "W", "HYGIENE", Color("75e0c0")],
]

signal warning_cue_requested(cue: StringName)

var snapshot: Dictionary = {}
var _warnings := WarningMonitor.new()
var _display: Dictionary = {}

func set_snapshot(next_snapshot: Dictionary) -> void:
	snapshot = next_snapshot
	if snapshot.get("state") == RunStateMachine.State.RUNNING:
		for cue in _warnings.update(snapshot["parameters"], Time.get_ticks_msec() / 1000.0):
			warning_cue_requested.emit(cue)
	else:
		_warnings.reset()
	queue_redraw()

func _process(delta: float) -> void:
	if snapshot.is_empty():
		return
	# Meters ease toward their true value instead of jumping per decay tick.
	for parameter_id in snapshot["parameters"]:
		var target: float = snapshot["parameters"][parameter_id]
		var current: float = _display.get(parameter_id, target)
		_display[parameter_id] = lerpf(current, target, minf(1.0, delta * 7.0))
	# Continuous redraw drives meter easing and the warning pulse.
	queue_redraw()

func _draw() -> void:
	if snapshot.is_empty(): return
	var panel_rect := Rect2(18, 18, 684, 275)
	var panel := StyleBoxFlat.new(); panel.bg_color = Color(0.05, 0.11, 0.24, 0.92); panel.border_color = Color("f5cf72"); panel.set_border_width_all(2); panel.set_corner_radius_all(24)
	panel.shadow_color = Color(0.0, 0.02, 0.08, 0.45); panel.shadow_size = 8
	draw_style_box(panel, panel_rect)
	var sheen := StyleBoxFlat.new(); sheen.bg_color = Color(1, 1, 1, 0.06); sheen.corner_radius_top_left = 22; sheen.corner_radius_top_right = 22
	draw_style_box(sheen, Rect2(panel_rect.position + Vector2(3, 3), Vector2(panel_rect.size.x - 6, 62)))
	var font := ThemeDB.fallback_font
	draw_string(font, Vector2(42, 58), "WANDERING TOURIST", HORIZONTAL_ALIGNMENT_LEFT, -1, 26, Color("fff0bd")); draw_string(font, Vector2(42, 82), "STAGE %d  |  %s" % [snapshot.get("stage", 1), _theme_label()], HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color("8ce4d8"))
	_draw_stage_dots(330, 76)
	var values: Dictionary = snapshot["parameters"]
	var active_parameters: Array = snapshot.get("active_parameters", [&"hunger", &"rest", &"fun"])
	var meter_y := 106.0
	for spec in PARAMETER_SPECS:
		var parameter_id: StringName = spec[0]
		if not active_parameters.has(parameter_id):
			continue
		var value: float = values.get(parameter_id, 50.0)
		_draw_meter(42, meter_y, spec[1], spec[2], value, _display.get(parameter_id, value), spec[3])
		meter_y += 27.0
	draw_string(font, Vector2(506, 125), "TIME  %02d:%02d" % [int(snapshot["remaining"]) / 60, int(snapshot["remaining"]) % 60], HORIZONTAL_ALIGNMENT_LEFT, -1, 19, Color.WHITE)
	draw_string(font, Vector2(506, 164), "SCORE  %d" % snapshot["score"], HORIZONTAL_ALIGNMENT_LEFT, -1, 19, Color("fff0bd")); draw_string(font, Vector2(506, 196), "SPIRIT", HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color("8ce4d8")); _draw_spirit_pips(506, 206, snapshot.get("momentum", 0)); draw_string(font, Vector2(42, 282), snapshot.get("objective", ""), HORIZONTAL_ALIGNMENT_LEFT, -1, 15, Color("fff0bd"))
	_draw_coins(font)
	_draw_priority(font)

func _draw_coins(font: Font) -> void:
	draw_circle(Vector2(518, 238), 10, Color("f6c85f"))
	draw_circle(Vector2(518, 238), 7, Color("fff0bd"))
	draw_string(font, Vector2(536, 244), "COINS  %d" % snapshot.get("wallet_coins", 0), HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color("ffe08a"))

func _draw_priority(font: Font) -> void:
	var parameter_id: StringName = snapshot.get("priority_parameter", &"hunger")
	var label: String = {"hunger": "HUNGER", "rest": "REST", "fun": "FUN", "social": "SOCIAL", "hygiene": "HYGIENE"}.get(parameter_id, "NEEDS")
	var value: int = int(round(snapshot.get("priority_value", 50.0)))
	var chip := StyleBoxFlat.new()
	chip.bg_color = Color("102b4a")
	chip.border_color = Color("ffcf76") if value <= 35 else Color("8ce4d8")
	chip.set_border_width_all(2)
	chip.set_corner_radius_all(11)
	draw_style_box(chip, Rect2(470, 258, 220, 30))
	draw_string(font, Vector2(484, 279), "PRIORITY  %s  %02d" % [label, value], HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Color("fff0bd"))

func _theme_label() -> String:
	return String(snapshot.get("stage_title", "ISLAND JOURNEY")).trim_prefix("LEVEL %02d - " % snapshot.get("stage", 1))

func _draw_spirit_pips(x: float, y: float, momentum: int) -> void:
	for index in 9:
		var center := Vector2(x + index * 20, y)
		if index < momentum:
			draw_circle(center, 6, Color("ffcf5c"))
			draw_circle(center + Vector2(-1.5, -1.5), 2.5, Color("fff3c4"))
		else:
			draw_arc(center, 6, 0, TAU, 12, Color(0.55, 0.75, 0.72, 0.5), 1.5)

func _draw_stage_dots(x: float, y: float) -> void:
	for index in TOTAL_STAGES:
		var center := Vector2(x + index * 22, y)
		if index < snapshot.get("stage", 1):
			draw_circle(center, 6, Color("ffe08a"))
		else:
			draw_arc(center, 6, 0, TAU, 16, Color("8ce4d8"), 2.0)

func _draw_meter(x: float, y: float, icon: String, label: String, value: float, shown: float, tint: Color) -> void:
	var warning := value <= WarningMonitor.LOW_BAND or value >= WarningMonitor.HIGH_BAND
	var alert := Color("ffdf80")
	if warning and not AppSettings.reduced_motion:
		alert.a = 0.55 + 0.45 * (0.5 + 0.5 * sin(Time.get_ticks_msec() / 1000.0 * TAU * 1.2))
	# Parameter icon badge with a glossy dot.
	var badge := StyleBoxFlat.new(); badge.bg_color = tint.darkened(0.15); badge.set_corner_radius_all(13)
	draw_style_box(badge, Rect2(x - 1, y - 20, 26, 26))
	draw_circle(Vector2(x + 7, y - 12), 4, Color(1, 1, 1, 0.25))
	draw_string(ThemeDB.fallback_font, Vector2(x + 7, y - 1), icon, HORIZONTAL_ALIGNMENT_LEFT, -1, 15, Color("13213c")); draw_string(ThemeDB.fallback_font, Vector2(x + 34, y), label, HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color.WHITE)
	# Rounded bar with safe-zone ticks at 20 and 80.
	var bar_rect := Rect2(x + 122, y - 14, 250, 15)
	var bar_bg := StyleBoxFlat.new(); bar_bg.bg_color = Color("142b49"); bar_bg.set_corner_radius_all(7)
	draw_style_box(bar_bg, bar_rect)
	var fill_fraction := clampf(shown / 100.0, 0.0, 1.0)
	if fill_fraction > 0.02:
		var bar_fill := StyleBoxFlat.new(); bar_fill.bg_color = tint if not warning else alert; bar_fill.set_corner_radius_all(7)
		draw_style_box(bar_fill, Rect2(bar_rect.position, Vector2(bar_rect.size.x * fill_fraction, bar_rect.size.y)))
	for mark in [0.2, 0.8]:
		draw_line(bar_rect.position + Vector2(bar_rect.size.x * mark, 1), bar_rect.position + Vector2(bar_rect.size.x * mark, bar_rect.size.y - 1), Color(1, 1, 1, 0.35), 1.5)
	draw_rect(bar_rect, alert if warning else Color(1, 1, 1, 0.55), false, 2.0 if warning else 1.0)
	draw_string(ThemeDB.fallback_font, Vector2(x + 385, y), "%02d" % int(round(value)), HORIZONTAL_ALIGNMENT_LEFT, -1, 17, alert if warning else Color.WHITE)
	if warning: draw_string(ThemeDB.fallback_font, Vector2(x + 426, y), "!", HORIZONTAL_ALIGNMENT_LEFT, -1, 20, alert)
