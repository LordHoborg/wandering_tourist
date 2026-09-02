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
var familiarity_count: int = 0
var decision := "COLLECT"

func configure(data: Dictionary) -> void:
	item_id = data["id"]; collect = data["collect"]; tradeoff = data["tradeoff"]; cut_ready = data["cut_ready"]; knowledge = data.get("knowledge", "KNOWN"); familiarity_count = data.get("familiarity_count", 0); show_effects = data.get("show_effects", false); deltas = data.get("deltas", {}); decision = data.get("decision", "COLLECT")
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
	var card_rect := Rect2(Vector2.ZERO, size)
	# Drop shadow.
	var shadow := StyleBoxFlat.new(); shadow.bg_color = Color(0.0, 0.02, 0.06, 0.38); shadow.set_corner_radius_all(18)
	draw_style_box(shadow, Rect2(Vector2(3, 5), card_rect.size))
	if cut_ready:
		var glow := StyleBoxFlat.new(); glow.bg_color = Color(0, 0, 0, 0); glow.border_color = Color(1.0, 0.88, 0.55, 0.45); glow.set_border_width_all(3); glow.set_corner_radius_all(22)
		draw_style_box(glow, card_rect.grow(5))
	var card := StyleBoxFlat.new(); card.bg_color = Color(0.07, 0.13, 0.25, 0.97); card.border_color = Color("ffe597") if cut_ready else accent; card.set_border_width_all(4 if cut_ready else 2); card.set_corner_radius_all(18)
	draw_style_box(card, card_rect)
	# Category header band.
	var band := StyleBoxFlat.new(); band.bg_color = accent; band.corner_radius_top_left = 16; band.corner_radius_top_right = 16
	draw_style_box(band, Rect2(2, 2, card_rect.size.x - 4, 24))
	draw_string(ThemeDB.fallback_font, Vector2(12, 19), _title(), HORIZONTAL_ALIGNMENT_LEFT, 92, 13, Color(0.05, 0.10, 0.20))
	draw_string(ThemeDB.fallback_font, Vector2(96, 19), "MIXED" if tradeoff else _knowledge_label(), HORIZONTAL_ALIGNMENT_LEFT, 46, 9, Color(0.05, 0.10, 0.20, 0.75))
	# Icon on a soft backdrop.
	draw_circle(Vector2(37, 60), 24, Color(1, 1, 1, 0.10)); draw_circle(Vector2(37, 60), 24, Color(1, 1, 1, 0.14), false, 1.5)
	_draw_icon(Vector2(37, 60))
	if show_effects:
		_draw_effect_chips(Vector2(70, 44))
	if cut_ready:
		draw_string(ThemeDB.fallback_font, Vector2(70, 84), "ACTION!", HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Color("fff1b0"))
	_draw_decision_badge()

func _draw_decision_badge() -> void:
	var good := decision == "COLLECT" or decision == "GOOD CHOICE"
	var neutral := decision == "LET PASS" or decision == "SAVE IT"
	var tint := Color("92e7b0") if good else (Color("ffcf76") if neutral else Color("ff958b"))
	var badge := StyleBoxFlat.new()
	badge.bg_color = Color(tint, 0.88)
	badge.set_corner_radius_all(7)
	draw_style_box(badge, Rect2(8, 94, size.x - 16, 14))
	draw_string(ThemeDB.fallback_font, Vector2(14, 105), decision, HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color("101c34"))

func _draw_effect_chips(origin: Vector2) -> void:
	var names := {&"hunger": "H", &"rest": "R", &"fun": "F"}
	var index := 0
	for parameter_id in deltas:
		var amount: float = deltas[parameter_id]
		var chip_color := Color(0.30, 0.75, 0.45) if amount > 0 else Color(0.85, 0.38, 0.34)
		var pos := origin + Vector2(0, index * 17)
		var chip := StyleBoxFlat.new(); chip.bg_color = chip_color; chip.set_corner_radius_all(8)
		draw_style_box(chip, Rect2(pos, Vector2(52, 15)))
		draw_string(ThemeDB.fallback_font, pos + Vector2(5, 12), "%s%+d" % [names.get(parameter_id, "?"), int(amount)], HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color(0.04, 0.08, 0.16))
		index += 1

func _title() -> String:
	return {&"fruit": "FRUIT", &"pillow": "PILLOW", &"camera": "CAMERA", &"stale_snack": "STALE SNACK", &"alarm_clock": "ALARM", &"rain_cloud": "RAIN CLOUD", &"coffee": "COFFEE", &"local_meal": "LOCAL MEAL", &"night_market": "NIGHT MARKET"}.get(item_id, "ITEM")

func _knowledge_label() -> String:
	if knowledge == "KNOWN":
		return "KNOWN"
	if knowledge == "LEARNING":
		return "LRN %d/6" % familiarity_count
	return "NEW"

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
