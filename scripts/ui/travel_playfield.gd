class_name TravelPlayfield
extends Control

const LANE_TOP := 300.0
const LANE_HEIGHT := 680.0
const CUT_START := 850.0
var cut_ready: Array[bool] = [false, false]

func set_cut_ready(left_ready: bool, right_ready: bool) -> void:
	cut_ready = [left_ready, right_ready]
	queue_redraw()

func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, size), Color("172a4d"))
	for band in range(12):
		var t := float(band) / 11.0
		draw_rect(Rect2(0, band * 82, size.x, 84), Color(0.12 + t * 0.58, 0.20 + t * 0.22, 0.42 + t * 0.08))
	draw_circle(Vector2(560, 245), 96, Color("ffd475")); draw_circle(Vector2(560, 245), 70, Color("ffe6a4"))
	draw_rect(Rect2(0, 610, size.x, 670), Color("126b86")); draw_rect(Rect2(0, 720, size.x, 560), Color("0b506f"))
	for y in [750.0, 815.0, 1060.0]: draw_line(Vector2(0, y), Vector2(size.x, y), Color(0.45, 0.88, 0.9, 0.22), 3.0)
	var island := PackedVector2Array([Vector2(0, 645), Vector2(120, 570), Vector2(245, 635), Vector2(370, 545), Vector2(520, 640), Vector2(720, 560), Vector2(720, 710), Vector2(0, 710)])
	draw_colored_polygon(island, Color("17494c"))
	for x in [85.0, 325.0, 640.0]:
		draw_line(Vector2(x, 620), Vector2(x + 12, 520), Color("123e42"), 12.0); draw_circle(Vector2(x + 5, 510), 38, Color("15554f"))
	for lane in range(2):
		var x := 40.0 if lane == 0 else 380.0
		var panel := StyleBoxFlat.new(); panel.bg_color = Color(0.04, 0.12, 0.26, 0.56); panel.border_color = Color("7ee1d7"); panel.set_border_width_all(2); panel.set_corner_radius_all(22)
		draw_style_box(panel, Rect2(x, LANE_TOP, 300, LANE_HEIGHT))
		draw_rect(Rect2(x + 12, CUT_START, 276, 130), Color(0.98, 0.69, 0.24, 0.28 if cut_ready[lane] else 0.12))
		draw_line(Vector2(x + 15, 922), Vector2(x + 285, 922), Color("ffe08a") if cut_ready[lane] else Color("8bbec5"), 5.0)
		draw_string(ThemeDB.fallback_font, Vector2(x + 25, 960), "ACTION LINE", HORIZONTAL_ALIGNMENT_LEFT, -1, 15, Color("ffe9af"))
		if cut_ready[lane]: draw_string(ThemeDB.fallback_font, Vector2(x + 96, 885), "TAP NOW", HORIZONTAL_ALIGNMENT_LEFT, -1, 21, Color("fff2ba"))
