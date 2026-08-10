class_name TravelOverlay
extends Control

var snapshot: Dictionary = {}
func set_snapshot(next_snapshot: Dictionary) -> void:
	snapshot = next_snapshot; visible = not snapshot.is_empty() and snapshot["state"] != RunStateMachine.State.RUNNING; queue_redraw()

func _draw() -> void:
	if snapshot.is_empty(): return
	draw_rect(Rect2(Vector2.ZERO, size), Color(0.01, 0.03, 0.10, 0.70))
	var panel := StyleBoxFlat.new(); panel.bg_color = Color("132846"); panel.border_color = Color("ffe08a"); panel.set_border_width_all(3); panel.set_corner_radius_all(28); draw_style_box(panel, Rect2(72, 405, 576, 390))
	var state: int = snapshot["state"]; var title := "PAUSED"; var subtitle := "Take a breath. The island waits."
	if state == RunStateMachine.State.FAILED: title = "TRIP OVER"; subtitle = "%s needs attention." % String(snapshot.get("failure_parameter", "YOUR TRAVELER")).capitalize()
	elif state == RunStateMachine.State.COMPLETED: title = "DESTINATION REACHED"; subtitle = "A postcard-perfect journey. +500 bonus!"
	var stars: int = mini(3, 1 + int(snapshot.get("correct_decisions", 0) >= 8) + int(snapshot.get("missed_beneficial", 0) == 0))
	draw_string(ThemeDB.fallback_font, Vector2(120, 495), title, HORIZONTAL_ALIGNMENT_CENTER, 480, 30, Color("fff0bd")); draw_string(ThemeDB.fallback_font, Vector2(120, 536), subtitle, HORIZONTAL_ALIGNMENT_CENTER, 480, 18, Color("a8e5dc")); draw_string(ThemeDB.fallback_font, Vector2(170, 610), "SCORE  %d" % snapshot["score"], HORIZONTAL_ALIGNMENT_LEFT, -1, 25, Color.WHITE); draw_string(ThemeDB.fallback_font, Vector2(170, 650), "TRAVELER RATING  %s" % ("*".repeat(stars)), HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Color("ffe08a")); draw_string(ThemeDB.fallback_font, Vector2(120, 734), "SPACE TO RESUME    R TO RESTART" if state == RunStateMachine.State.PAUSED else ("N FOR NEXT STAGE    R TO RETRY" if state == RunStateMachine.State.COMPLETED and snapshot.get("stage", 1) < 3 else "PRESS R TO START A NEW TRIP"), HORIZONTAL_ALIGNMENT_CENTER, 480, 17, Color.WHITE)
