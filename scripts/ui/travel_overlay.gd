class_name TravelOverlay
extends Control

var snapshot: Dictionary = {}
func set_snapshot(next_snapshot: Dictionary) -> void:
	snapshot = next_snapshot; visible = not snapshot.is_empty() and snapshot["state"] != RunStateMachine.State.RUNNING; queue_redraw()

func _draw() -> void:
	if snapshot.is_empty(): return
	draw_rect(Rect2(Vector2.ZERO, size), Color(0.01, 0.03, 0.10, 0.72))
	var panel_rect := Rect2(72, 385, 576, 445)
	var shadow := StyleBoxFlat.new(); shadow.bg_color = Color(0, 0, 0, 0.4); shadow.set_corner_radius_all(30); draw_style_box(shadow, panel_rect.grow_side(SIDE_BOTTOM, 8).grow_side(SIDE_RIGHT, 6))
	var panel := StyleBoxFlat.new(); panel.bg_color = Color("162c4c"); panel.border_color = Color("ffe08a"); panel.set_border_width_all(3); panel.set_corner_radius_all(28); draw_style_box(panel, panel_rect)
	var sheen := StyleBoxFlat.new(); sheen.bg_color = Color(1, 1, 1, 0.05); sheen.corner_radius_top_left = 26; sheen.corner_radius_top_right = 26; draw_style_box(sheen, Rect2(panel_rect.position + Vector2(4, 4), Vector2(panel_rect.size.x - 8, 120)))
	var state: int = snapshot["state"]; var title := "PAUSED"; var subtitle := "Take a breath. The island waits."
	var final_stage: bool = snapshot.get("stage", 1) >= 3
	if state == RunStateMachine.State.FAILED: title = "TRIP OVER"; subtitle = "%s needs attention." % String(snapshot.get("failure_parameter", "YOUR TRAVELER")).capitalize()
	elif state == RunStateMachine.State.COMPLETED:
		if final_stage: title = "JOURNEY COMPLETE"; subtitle = "Every stage cleared. The tourist wanders on."
		else: title = "DESTINATION REACHED"; subtitle = "A postcard-perfect journey. +%d bonus!" % snapshot.get("bonus", 500)
	var stars: int = mini(3, 1 + int(snapshot.get("correct_decisions", 0) >= 8) + int(snapshot.get("missed_beneficial", 0) == 0))
	var continue_text := "TAP HERE OR SPACE / ENTER / N TO CONTINUE"
	var action_text: String = "SPACE TO RESUME    R TWICE TO RESTART" if state == RunStateMachine.State.PAUSED else (continue_text if state == RunStateMachine.State.COMPLETED and not final_stage else "PRESS R TO START A NEW TRIP")
	var font := ThemeDB.fallback_font
	draw_string(font, Vector2(120, 470), title, HORIZONTAL_ALIGNMENT_CENTER, 480, 30, Color("fff0bd"))
	draw_string(font, Vector2(120, 508), subtitle, HORIZONTAL_ALIGNMENT_CENTER, 480, 18, Color("a8e5dc"))
	for index in 3:
		_draw_star(Vector2(300 + index * 60, 552), 20, index < stars)
	draw_string(font, Vector2(170, 612), "SCORE  %d" % snapshot["score"], HORIZONTAL_ALIGNMENT_LEFT, -1, 25, Color.WHITE); draw_string(font, Vector2(400, 612), "BEST  %d" % snapshot.get("best_score", 0), HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Color("ffe08a"))
	draw_string(font, Vector2(170, 652), "TAKEN %d   MISSED %d" % [snapshot.get("beneficial_collected", 0), snapshot.get("missed_beneficial", 0)], HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color.WHITE)
	draw_string(font, Vector2(170, 684), "HAZARDS: PASSED %d  CUT %d" % [snapshot.get("hazards_passed", 0), snapshot.get("hazards_cut", 0)], HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color.WHITE)
	draw_string(font, Vector2(170, 716), "MIXED: GOOD %d  TAKEN %d" % [snapshot.get("beneficial_tradeoffs", 0), snapshot.get("tradeoffs_taken", 0)], HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color("a8e5dc"))
	draw_string(font, Vector2(120, 782), action_text, HORIZONTAL_ALIGNMENT_CENTER, 480, 17, Color.WHITE)

func _draw_star(center: Vector2, radius: float, filled: bool) -> void:
	var points := PackedVector2Array()
	for index in 10:
		var angle := -PI / 2.0 + index * PI / 5.0
		var r := radius if index % 2 == 0 else radius * 0.45
		points.append(center + Vector2(cos(angle), sin(angle)) * r)
	if filled:
		draw_colored_polygon(points, Color("ffe08a"))
	else:
		points.append(points[0])
		draw_polyline(points, Color(1, 0.88, 0.54, 0.45), 2.0)
