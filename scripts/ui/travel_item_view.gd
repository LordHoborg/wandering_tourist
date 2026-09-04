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
var coin_reward := 0
var bonus_kind: StringName = &""

func configure(data: Dictionary) -> void:
	item_id = data["id"]; collect = data["collect"]; tradeoff = data["tradeoff"]; cut_ready = data["cut_ready"]; knowledge = data.get("knowledge", "KNOWN"); familiarity_count = data.get("familiarity_count", 0); show_effects = data.get("show_effects", false); deltas = data.get("deltas", {}); decision = data.get("decision", "COLLECT"); coin_reward = data.get("coin_reward", 0); bonus_kind = data.get("bonus_kind", &"")
	accent = _bonus_color() if not bonus_kind.is_empty() else (Color("c88cff") if tradeoff else (Color("8fe3a8") if collect else Color("ff917b")))
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
	var shadow := StyleBoxFlat.new(); shadow.bg_color = Color(0.0, 0.02, 0.06, 0.48); shadow.set_corner_radius_all(20)
	draw_style_box(shadow, Rect2(Vector2(4, 6), card_rect.size))
	if cut_ready:
		var glow := StyleBoxFlat.new(); glow.bg_color = Color(0, 0, 0, 0); glow.border_color = Color(1.0, 0.88, 0.55, 0.52); glow.set_border_width_all(3); glow.set_corner_radius_all(22)
		draw_style_box(glow, card_rect.grow(5))
	var card := StyleBoxFlat.new(); card.bg_color = Color("0b1930"); card.border_color = Color("ffe597") if cut_ready else Color(accent, 0.86); card.set_border_width_all(3 if cut_ready else 2); card.set_corner_radius_all(20)
	draw_style_box(card, card_rect)
	var top_glow := StyleBoxFlat.new(); top_glow.bg_color = Color(accent, 0.16); top_glow.corner_radius_top_left = 18; top_glow.corner_radius_top_right = 18
	draw_style_box(top_glow, Rect2(3, 3, card_rect.size.x - 6, 34))
	draw_line(Vector2(12, 36), Vector2(size.x - 12, 36), Color(accent, 0.46), 1.0)
	draw_string(ThemeDB.fallback_font, Vector2(12, 20), _title(), HORIZONTAL_ALIGNMENT_LEFT, 108, 11, Color("fff4d0"))
	draw_string(ThemeDB.fallback_font, Vector2(114, 20), "MIXED" if tradeoff else _knowledge_label(), HORIZONTAL_ALIGNMENT_LEFT, 38, 8, Color(accent, 0.9))
	var icon_plate := StyleBoxFlat.new(); icon_plate.bg_color = Color(1, 1, 1, 0.08); icon_plate.border_color = Color(1, 1, 1, 0.16); icon_plate.set_border_width_all(1); icon_plate.set_corner_radius_all(26)
	draw_style_box(icon_plate, Rect2(9, 42, 56, 48))
	draw_circle(Vector2(37, 64), 21, Color(0.01, 0.04, 0.10, 0.34))
	_draw_icon(Vector2(37, 62))
	draw_circle(Vector2(23, 49), 4, Color(1, 1, 1, 0.20))
	if show_effects:
		_draw_effect_chips(Vector2(70, 45))
	if coin_reward > 0:
		draw_circle(Vector2(83, 65), 9, Color("f6c85f"))
		draw_circle(Vector2(83, 65), 6, Color("fff0bd"))
		draw_string(ThemeDB.fallback_font, Vector2(98, 70), "+%d COINS" % coin_reward, HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color("ffe08a"))
	elif bonus_kind == &"balance":
		draw_string(ThemeDB.fallback_font, Vector2(74, 70), "CENTER ALL NEEDS", HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color("a7f1ca"))
	elif bonus_kind == &"time":
		draw_string(ThemeDB.fallback_font, Vector2(82, 70), "SKIP 8 SEC", HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color("91b9ff"))
	if cut_ready:
		draw_string(ThemeDB.fallback_font, Vector2(70, 84), "ACTION!", HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color("fff1b0"))
	_draw_decision_badge()

func _draw_decision_badge() -> void:
	var good := decision == "COLLECT" or decision == "GOOD CHOICE"
	var neutral := decision == "LET PASS" or decision == "SAVE IT" or decision == "WAIT"
	var tint := Color("92e7b0") if good else (Color("ffcf76") if neutral else Color("ff958b"))
	var badge := StyleBoxFlat.new()
	badge.bg_color = Color(tint, 0.94)
	badge.border_color = Color(1, 1, 1, 0.22)
	badge.set_border_width_all(1)
	badge.set_corner_radius_all(8)
	draw_style_box(badge, Rect2(8, 94, size.x - 16, 14))
	draw_string(ThemeDB.fallback_font, Vector2(14, 105), decision, HORIZONTAL_ALIGNMENT_LEFT, -1, 9, Color("101c34"))

func _draw_effect_chips(origin: Vector2) -> void:
	var names := {&"hunger": "H", &"rest": "R", &"fun": "F", &"social": "S", &"hygiene": "W"}
	var index := 0
	for parameter_id in deltas:
		var amount: float = deltas[parameter_id]
		var chip_color := Color(0.30, 0.75, 0.45) if amount > 0 else Color(0.85, 0.38, 0.34)
		var pos := origin + Vector2((index % 2) * 45, (index / 2) * 17)
		var chip := StyleBoxFlat.new(); chip.bg_color = chip_color; chip.set_corner_radius_all(8)
		draw_style_box(chip, Rect2(pos, Vector2(42, 15)))
		draw_string(ThemeDB.fallback_font, pos + Vector2(5, 12), "%s%+d" % [names.get(parameter_id, "?"), int(amount)], HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color(0.04, 0.08, 0.16))
		index += 1

func _title() -> String:
	return {&"fruit": "FRUIT", &"pillow": "PILLOW", &"camera": "CAMERA", &"stale_snack": "STALE SNACK", &"alarm_clock": "ALARM", &"rain_cloud": "RAIN CLOUD", &"friend_group": "FRIENDS", &"awkward_meeting": "AWKWARD", &"soap": "SOAP", &"muddy_shoes": "MUDDY", &"coffee": "COFFEE", &"local_meal": "LOCAL MEAL", &"night_market": "NIGHT MARKET", &"street_festival": "FESTIVAL", &"spa_day": "SPA DAY", &"group_tour": "GROUP TOUR", &"golden_coconut": "GOLDEN COCONUT", &"coin_bubble": "YELLOW BUBBLE", &"balance_bubble": "GREEN BUBBLE", &"time_bubble": "BLUE BUBBLE"}.get(item_id, "ITEM")

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
	elif item_id == &"friend_group": draw_circle(c + Vector2(-12, -5), 8, Color("ffd370")); draw_circle(c + Vector2(12, -5), 8, Color("9ee276")); draw_line(c + Vector2(-18, 22), c + Vector2(-10, 6), Color("ffd370"), 7); draw_line(c + Vector2(18, 22), c + Vector2(10, 6), Color("9ee276"), 7)
	elif item_id == &"awkward_meeting": draw_rect(Rect2(c - Vector2(24, 14), Vector2(48, 28)), Color("a88cff")); draw_circle(c + Vector2(-10, 0), 5, Color("ffe08a")); draw_circle(c + Vector2(10, 0), 5, Color("ffe08a")); draw_line(c + Vector2(-15, 20), c + Vector2(15, 20), Color("ff917b"), 3)
	elif item_id == &"soap": draw_rect(Rect2(c - Vector2(20, 14), Vector2(40, 28)), Color("75e0c0")); draw_circle(c + Vector2(-8, -19), 5, Color(1, 1, 1, 0.6)); draw_circle(c + Vector2(8, -24), 3, Color(1, 1, 1, 0.5))
	elif item_id == &"muddy_shoes": draw_rect(Rect2(c - Vector2(20, 5), Vector2(18, 20)), Color("8b5d47")); draw_rect(Rect2(c + Vector2(3, -10), Vector2(18, 25)), Color("6f4b42")); draw_circle(c + Vector2(-10, 21), 7, Color("5b3d35")); draw_circle(c + Vector2(13, 17), 7, Color("5b3d35"))
	elif item_id == &"street_festival": draw_circle(c, 21, Color("f49ad6")); draw_line(c + Vector2(-25, -17), c + Vector2(25, -17), Color("ffe08a"), 4); draw_line(c + Vector2(-15, -17), c + Vector2(-15, -28), Color("ffe08a"), 3); draw_line(c + Vector2(15, -17), c + Vector2(15, -28), Color("ffe08a"), 3)
	elif item_id == &"spa_day": draw_circle(c, 22, Color("75e0c0")); draw_circle(c + Vector2(0, -8), 8, Color("fff0bd")); draw_arc(c + Vector2(0, 6), 13, 0.2, PI - 0.2, 12, Color("fff0bd"), 4)
	elif item_id == &"group_tour": draw_circle(c + Vector2(-11, -5), 8, Color("ffd370")); draw_circle(c + Vector2(11, -5), 8, Color("a88cff")); draw_line(c + Vector2(-17, 21), c + Vector2(-8, 5), Color("ffd370"), 6); draw_line(c + Vector2(17, 21), c + Vector2(8, 5), Color("a88cff"), 6)
	elif item_id == &"golden_coconut": draw_circle(c, 21, Color("f6c85f")); draw_circle(c, 15, Color("fff0bd")); draw_line(c + Vector2(-8, 0), c + Vector2(8, 0), Color("b8782a"), 3); draw_circle(c + Vector2(-6, -7), 3, Color("b8782a")); draw_circle(c + Vector2(6, 7), 3, Color("b8782a"))
	elif item_id == &"coin_bubble": draw_circle(c, 23, Color("f6c85f")); draw_circle(c, 17, Color("fff0bd")); draw_string(ThemeDB.fallback_font, c + Vector2(-7, 7), "$", HORIZONTAL_ALIGNMENT_LEFT, -1, 22, Color("9b6529"))
	elif item_id == &"balance_bubble": draw_circle(c, 23, Color("61d48d")); draw_circle(c, 16, Color("c9f7d7")); draw_line(c + Vector2(-8, 0), c + Vector2(8, 0), Color("287b54"), 4); draw_line(c + Vector2(0, -8), c + Vector2(0, 8), Color("287b54"), 4)
	elif item_id == &"time_bubble": draw_circle(c, 23, Color("6caeff")); draw_circle(c, 16, Color("d5e9ff")); draw_arc(c, 9, -PI * 0.35, PI * 1.25, 18, Color("275b9b"), 3); draw_colored_polygon(PackedVector2Array([c + Vector2(5, -10), c + Vector2(12, -8), c + Vector2(8, -3)]), Color("275b9b"))
	else: draw_rect(Rect2(c - Vector2(23, 14), Vector2(46, 29)), Color("db7ede")); draw_line(c + Vector2(-25, -14), c + Vector2(25, -14), Color("ffe08a"), 5); draw_line(c + Vector2(-15, -24), c + Vector2(-15, -14), Color("ffe08a"), 3); draw_line(c + Vector2(15, -24), c + Vector2(15, -14), Color("ffe08a"), 3)

func _bonus_color() -> Color:
	return {
		&"coins": Color("f6c85f"),
		&"balance": Color("61d48d"),
		&"time": Color("6caeff"),
	}.get(bonus_kind, Color("f6c85f"))
