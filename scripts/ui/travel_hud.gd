class_name TravelHud
extends Control

var snapshot: Dictionary = {}
func set_snapshot(next_snapshot: Dictionary) -> void:
	snapshot = next_snapshot
	queue_redraw()

func _draw() -> void:
	if snapshot.is_empty(): return
	var panel := StyleBoxFlat.new(); panel.bg_color = Color(0.035, 0.08, 0.18, 0.88); panel.border_color = Color("f5cf72"); panel.set_border_width_all(2); panel.set_corner_radius_all(24)
	draw_style_box(panel, Rect2(18, 18, 684, 244))
	var font := ThemeDB.fallback_font
	draw_string(font, Vector2(42, 58), "WANDERING TOURIST", HORIZONTAL_ALIGNMENT_LEFT, -1, 26, Color("fff0bd")); draw_string(font, Vector2(42, 82), "TROPICAL POSTCARD RUN", HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color("8ce4d8"))
	var values: Dictionary = snapshot["parameters"]
	_draw_meter(42, 112, "H", "HUNGER", values[&"hunger"], Color("ffb35c")); _draw_meter(42, 160, "Z", "REST", values[&"rest"], Color("91b9ff")); _draw_meter(42, 208, "*", "FUN", values[&"fun"], Color("f49ad6"))
	draw_string(font, Vector2(506, 125), "TIME  %02d:%02d" % [int(snapshot["remaining"]) / 60, int(snapshot["remaining"]) % 60], HORIZONTAL_ALIGNMENT_LEFT, -1, 19, Color.WHITE)
	draw_string(font, Vector2(506, 164), "SCORE  %d" % snapshot["score"], HORIZONTAL_ALIGNMENT_LEFT, -1, 19, Color("fff0bd")); draw_string(font, Vector2(506, 203), "BEST   %d" % snapshot["best_score"], HORIZONTAL_ALIGNMENT_LEFT, -1, 19, Color("8ce4d8"))

func _draw_meter(x: float, y: float, icon: String, label: String, value: float, tint: Color) -> void:
	var warning := value <= 30.0 or value >= 70.0
	draw_circle(Vector2(x + 12, y - 7), 13, tint.darkened(0.15)); draw_string(ThemeDB.fallback_font, Vector2(x + 7, y - 1), icon, HORIZONTAL_ALIGNMENT_LEFT, -1, 15, Color("13213c")); draw_string(ThemeDB.fallback_font, Vector2(x + 34, y), label, HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color.WHITE)
	draw_rect(Rect2(x + 122, y - 14, 290, 15), Color("142b49")); draw_rect(Rect2(x + 122, y - 14, 290 * clampf(value / 100.0, 0.0, 1.0), 15), tint if not warning else Color("ffcc52")); draw_rect(Rect2(x + 122, y - 14, 290, 15), Color.WHITE, false, 1.0)
	draw_string(ThemeDB.fallback_font, Vector2(x + 425, y), "%02d" % int(round(value)), HORIZONTAL_ALIGNMENT_LEFT, -1, 17, Color("ffdf80") if warning else Color.WHITE)
	if warning: draw_string(ThemeDB.fallback_font, Vector2(x + 466, y), "!", HORIZONTAL_ALIGNMENT_LEFT, -1, 20, Color("ffdf80"))
