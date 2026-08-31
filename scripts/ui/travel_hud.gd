class_name TravelHud
extends Control

const WarningMonitor = preload("res://scripts/ui/warning_monitor.gd")
const TOTAL_STAGES := 3

signal warning_cue_requested(cue: StringName)

var snapshot: Dictionary = {}
var _warnings := WarningMonitor.new()

func set_snapshot(next_snapshot: Dictionary) -> void:
	snapshot = next_snapshot
	if snapshot.get("state") == RunStateMachine.State.RUNNING:
		for cue in _warnings.update(snapshot["parameters"], Time.get_ticks_msec() / 1000.0):
			warning_cue_requested.emit(cue)
	else:
		_warnings.reset()
	queue_redraw()

func _draw() -> void:
	if snapshot.is_empty(): return
	var panel := StyleBoxFlat.new(); panel.bg_color = Color(0.035, 0.08, 0.18, 0.88); panel.border_color = Color("f5cf72"); panel.set_border_width_all(2); panel.set_corner_radius_all(24)
	draw_style_box(panel, Rect2(18, 18, 684, 244))
	var font := ThemeDB.fallback_font
	draw_string(font, Vector2(42, 58), "WANDERING TOURIST", HORIZONTAL_ALIGNMENT_LEFT, -1, 26, Color("fff0bd")); draw_string(font, Vector2(42, 82), "STAGE %d  |  TROPICAL POSTCARD RUN" % snapshot.get("stage", 1), HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color("8ce4d8"))
	_draw_stage_dots(268, 76)
	var values: Dictionary = snapshot["parameters"]
	_draw_meter(42, 112, "H", "HUNGER", values[&"hunger"], Color("ffb35c")); _draw_meter(42, 160, "Z", "REST", values[&"rest"], Color("91b9ff")); _draw_meter(42, 208, "*", "FUN", values[&"fun"], Color("f49ad6"))
	draw_string(font, Vector2(506, 125), "TIME  %02d:%02d" % [int(snapshot["remaining"]) / 60, int(snapshot["remaining"]) % 60], HORIZONTAL_ALIGNMENT_LEFT, -1, 19, Color.WHITE)
	draw_string(font, Vector2(506, 164), "SCORE  %d" % snapshot["score"], HORIZONTAL_ALIGNMENT_LEFT, -1, 19, Color("fff0bd")); draw_string(font, Vector2(506, 203), "SPIRIT %d/9" % snapshot.get("momentum", 0), HORIZONTAL_ALIGNMENT_LEFT, -1, 17, Color("8ce4d8")); draw_string(font, Vector2(42, 286), snapshot.get("objective", ""), HORIZONTAL_ALIGNMENT_LEFT, -1, 15, Color("fff0bd"))

func _draw_stage_dots(x: float, y: float) -> void:
	for index in TOTAL_STAGES:
		var center := Vector2(x + index * 22, y)
		if index < snapshot.get("stage", 1):
			draw_circle(center, 6, Color("ffe08a"))
		else:
			draw_arc(center, 6, 0, TAU, 16, Color("8ce4d8"), 2.0)

func _draw_meter(x: float, y: float, icon: String, label: String, value: float, tint: Color) -> void:
	var warning := value <= WarningMonitor.LOW_BAND or value >= WarningMonitor.HIGH_BAND
	var alert := Color("ffdf80")
	if warning and not AppSettings.reduced_motion:
		alert.a = 0.55 + 0.45 * (0.5 + 0.5 * sin(Time.get_ticks_msec() / 1000.0 * TAU * 1.2))
	draw_circle(Vector2(x + 12, y - 7), 13, tint.darkened(0.15)); draw_string(ThemeDB.fallback_font, Vector2(x + 7, y - 1), icon, HORIZONTAL_ALIGNMENT_LEFT, -1, 15, Color("13213c")); draw_string(ThemeDB.fallback_font, Vector2(x + 34, y), label, HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color.WHITE)
	draw_rect(Rect2(x + 122, y - 14, 290, 15), Color("142b49")); draw_rect(Rect2(x + 122, y - 14, 290 * clampf(value / 100.0, 0.0, 1.0), 15), tint if not warning else alert); draw_rect(Rect2(x + 122, y - 14, 290, 15), alert if warning else Color.WHITE, false, 2.0 if warning else 1.0)
	draw_string(ThemeDB.fallback_font, Vector2(x + 425, y), "%02d" % int(round(value)), HORIZONTAL_ALIGNMENT_LEFT, -1, 17, alert if warning else Color.WHITE)
	if warning: draw_string(ThemeDB.fallback_font, Vector2(x + 466, y), "!", HORIZONTAL_ALIGNMENT_LEFT, -1, 20, alert)
