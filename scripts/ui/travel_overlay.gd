class_name TravelOverlay
extends Control

var snapshot: Dictionary = {}
func set_snapshot(next_snapshot: Dictionary) -> void:
	snapshot = next_snapshot; visible = not snapshot.is_empty() and snapshot["state"] != RunStateMachine.State.RUNNING; queue_redraw()

func _draw() -> void:
	if snapshot.is_empty(): return
	draw_rect(Rect2(Vector2.ZERO, size), Color(0.01, 0.03, 0.10, 0.70))
	var panel := StyleBoxFlat.new(); panel.bg_color = Color("132846"); panel.border_color = Color("ffe08a"); panel.set_border_width_all(3); panel.set_corner_radius_all(28); draw_style_box(panel, Rect2(72, 385, 576, 445))
	var state: int = snapshot["state"]; var title := "PAUSED"; var subtitle := "Take a breath. The island waits."
	var final_stage: bool = snapshot.get("stage", 1) >= 3
	if state == RunStateMachine.State.FAILED: title = "TRIP OVER"; subtitle = "%s needs attention." % String(snapshot.get("failure_parameter", "YOUR TRAVELER")).capitalize()
	elif state == RunStateMachine.State.COMPLETED:
		if final_stage: title = "JOURNEY COMPLETE"; subtitle = "Every stage cleared. The tourist wanders on."
		else: title = "DESTINATION REACHED"; subtitle = "A postcard-perfect journey. +%d bonus!" % snapshot.get("bonus", 500)
	var stars: int = mini(3, 1 + int(snapshot.get("correct_decisions", 0) >= 8) + int(snapshot.get("missed_beneficial", 0) == 0))
	var continue_text := "TAP HERE OR SPACE / ENTER / N TO CONTINUE"
	var action_text: String = "SPACE TO RESUME    R TWICE TO RESTART" if state == RunStateMachine.State.PAUSED else (continue_text if state == RunStateMachine.State.COMPLETED and snapshot.get("stage", 1) < 3 else "PRESS R TO START A NEW TRIP")
	draw_string(ThemeDB.fallback_font, Vector2(120, 475), title, HORIZONTAL_ALIGNMENT_CENTER, 480, 30, Color("fff0bd")); draw_string(ThemeDB.fallback_font, Vector2(120, 516), subtitle, HORIZONTAL_ALIGNMENT_CENTER, 480, 18, Color("a8e5dc")); draw_string(ThemeDB.fallback_font, Vector2(170, 580), "SCORE  %d" % snapshot["score"], HORIZONTAL_ALIGNMENT_LEFT, -1, 25, Color.WHITE); draw_string(ThemeDB.fallback_font, Vector2(370, 580), "BEST  %d" % snapshot.get("best_score", 0), HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Color("ffe08a")); draw_string(ThemeDB.fallback_font, Vector2(170, 618), "TRAVELER RATING  %s" % ("*".repeat(stars)), HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Color("ffe08a")); draw_string(ThemeDB.fallback_font, Vector2(170, 658), "TAKEN %d   MISSED %d" % [snapshot.get("beneficial_collected", 0), snapshot.get("missed_beneficial", 0)], HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color.WHITE); draw_string(ThemeDB.fallback_font, Vector2(170, 690), "HAZARDS: PASSED %d  CUT %d" % [snapshot.get("hazards_passed", 0), snapshot.get("hazards_cut", 0)], HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color.WHITE); draw_string(ThemeDB.fallback_font, Vector2(170, 722), "MIXED: GOOD %d  TAKEN %d" % [snapshot.get("beneficial_tradeoffs", 0), snapshot.get("tradeoffs_taken", 0)], HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color("a8e5dc")); draw_string(ThemeDB.fallback_font, Vector2(120, 782), action_text, HORIZONTAL_ALIGNMENT_CENTER, 480, 17, Color.WHITE)
