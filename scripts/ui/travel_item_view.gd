class_name TravelItemView
extends Control

var item_id: StringName
var collect: bool
var tradeoff: bool
var cut_ready: bool
var accent := Color.WHITE
var knowledge := "NEW"
var show_effects := true
var deltas: Dictionary = {}

func configure(data: Dictionary) -> void:
	item_id = data["id"]; collect = data["collect"]; tradeoff = data["tradeoff"]; cut_ready = data["cut_ready"]; knowledge = data.get("knowledge", "KNOWN"); show_effects = data.get("show_effects", false); deltas = data.get("deltas", {})
	accent = Color("c88cff") if tradeoff else (Color("8fe3a8") if collect else Color("ff917b"))
	queue_redraw()

func play_spawn(reduced_motion: bool) -> void:
	if reduced_motion: return
	scale = Vector2(0.55, 0.55); pivot_offset = size * 0.5
	create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT).tween_property(self, "scale", Vector2.ONE, 0.28)

func play_departure(harmful: bool, reduced_motion: bool) -> void:
	var tween := create_tween()
	if not reduced_motion:
		tween.parallel().tween_property(self, "scale", Vector2(1.25, 0.65) if harmful else Vector2(1.35, 1.35), 0.12); tween.parallel().tween_property(self, "rotation", 0.15 if harmful else -0.1, 0.12)
	tween.parallel().tween_property(self, "modulate:a", 0.0, 0.22); tween.tween_callback(queue_free)

func _draw() -> void:
	var card := StyleBoxFlat.new(); card.bg_color = Color(0.05, 0.10, 0.20, 0.96); card.border_color = Color("ffe597") if cut_ready else accent; card.set_border_width_all(4 if cut_ready else 2); card.set_corner_radius_all(18)
	draw_style_box(card, Rect2(Vector2.ZERO, size)); _draw_icon(Vector2(38, 42))
	draw_string(ThemeDB.fallback_font, Vector2(77, 38), _title(), HORIZONTAL_ALIGNMENT_LEFT, 88, 15, Color.WHITE); draw_string(ThemeDB.fallback_font, Vector2(77, 61), "MIXED" if tradeoff else knowledge, HORIZONTAL_ALIGNMENT_LEFT, -1, 12, accent)
	if show_effects: draw_string(ThemeDB.fallback_font, Vector2(77, 80), _effect_text(), HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color("fff0bd"))
	if cut_ready: draw_string(ThemeDB.fallback_font, Vector2(18, 83), "ACTION!", HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Color("fff1b0"))

func _title() -> String:
	return {&"fruit": "FRUIT", &"pillow": "PILLOW", &"camera": "CAMERA", &"stale_snack": "STALE SNACK", &"alarm_clock": "ALARM", &"rain_cloud": "RAIN CLOUD", &"coffee": "COFFEE", &"local_meal": "LOCAL MEAL", &"night_market": "NIGHT MARKET"}.get(item_id, "ITEM")

func _effect_text() -> String:
	var names := {&"hunger": "H", &"rest": "R", &"fun": "F"}
	var chunks: Array[String] = []
	for parameter_id in deltas:
		chunks.append("%s%+d" % [names.get(parameter_id, "?"), int(deltas[parameter_id])])
	return " ".join(chunks)

func _draw_icon(c: Vector2) -> void:
	if item_id == &"fruit": draw_circle(c, 20, Color("ff885e")); draw_circle(c + Vector2(9, -12), 7, Color("9ee276"))
	elif item_id == &"pillow": draw_rect(Rect2(c - Vector2(23, 15), Vector2(46, 30)), Color("d5e8ff")); draw_circle(c + Vector2(-18, 0), 15, Color("d5e8ff")); draw_circle(c + Vector2(18, 0), 15, Color("d5e8ff"))
	elif item_id == &"camera": draw_rect(Rect2(c - Vector2(24, 16), Vector2(48, 32)), Color("ffd370")); draw_circle(c, 11, Color("31527a")); draw_rect(Rect2(c + Vector2(-12, -23), Vector2(18, 8)), Color("ffd370"))
	elif item_id == &"stale_snack": draw_rect(Rect2(c - Vector2(19, 22), Vector2(38, 44)), Color("d6a66b")); draw_line(c - Vector2(13, 12), c + Vector2(13, 12), Color("782d34"), 4); draw_line(c + Vector2(13, -12), c - Vector2(13, 12), Color("782d34"), 4)
	elif item_id == &"alarm_clock": draw_circle(c, 20, Color("ff7c74")); draw_circle(c, 14, Color("3c3158")); draw_line(c, c + Vector2(0, -9), Color.WHITE, 3); draw_line(c, c + Vector2(8, 4), Color.WHITE, 3)
	elif item_id == &"rain_cloud": draw_circle(c + Vector2(-10, 1), 13, Color("a9c4e8")); draw_circle(c + Vector2(5, -5), 17, Color("a9c4e8")); draw_circle(c + Vector2(18, 3), 11, Color("a9c4e8")); draw_line(c + Vector2(-7, 21), c + Vector2(-12, 31), Color("72c4ff"), 3); draw_line(c + Vector2(12, 20), c + Vector2(7, 30), Color("72c4ff"), 3)
	elif item_id == &"coffee": draw_rect(Rect2(c - Vector2(16, 14), Vector2(32, 30)), Color("f5d0a1")); draw_arc(c + Vector2(17, 0), 9, -1.4, 1.4, 12, Color("f5d0a1"), 4); draw_line(c + Vector2(-7, -22), c + Vector2(-3, -31), Color.WHITE, 2)
	elif item_id == &"local_meal": draw_circle(c, 24, Color("f8e2b1")); draw_circle(c, 17, Color("f18259")); draw_circle(c + Vector2(8, -4), 4, Color("88be62"))
	else: draw_rect(Rect2(c - Vector2(23, 14), Vector2(46, 29)), Color("db7ede")); draw_line(c + Vector2(-25, -14), c + Vector2(25, -14), Color("ffe08a"), 5); draw_line(c + Vector2(-15, -24), c + Vector2(-15, -14), Color("ffe08a"), 3); draw_line(c + Vector2(15, -24), c + Vector2(15, -14), Color("ffe08a"), 3)
