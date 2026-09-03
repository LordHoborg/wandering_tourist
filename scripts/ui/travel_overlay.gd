class_name TravelOverlay
extends Control

## Modal run-state overlay (pause/result). Emits `tapped` for touch/mouse so
## the composition root can resume/restart/advance without a keyboard.

signal tapped

var snapshot: Dictionary = {}
var _shown_at := -1.0
const TAP_GRACE_SECONDS := 0.4

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP

func set_snapshot(next_snapshot: Dictionary) -> void:
	var was_visible := visible
	snapshot = next_snapshot; visible = not snapshot.is_empty() and snapshot["state"] != RunStateMachine.State.RUNNING; queue_redraw()
	if visible and not was_visible:
		_shown_at = Time.get_ticks_msec() / 1000.0

func _gui_input(event: InputEvent) -> void:
	if (event is InputEventMouseButton or event is InputEventScreenTouch) and event.pressed:
		accept_event()
		# Ignore the tap that just produced this result; a result screen must
		# never be dismissed by the same touch that triggered it.
		if Time.get_ticks_msec() / 1000.0 - _shown_at < TAP_GRACE_SECONDS:
			return
		tapped.emit()

func _draw() -> void:
	if snapshot.is_empty(): return
	draw_rect(Rect2(Vector2.ZERO, size), Color(0.01, 0.03, 0.10, 0.72))
	var panel_rect := Rect2(52, 330, 616, 590)
	var state: int = snapshot["state"]
	var accent := Color("ffe08a")
	if state == RunStateMachine.State.FAILED:
		accent = Color("ff9b89")
	elif state == RunStateMachine.State.COMPLETED:
		accent = Color("8ce4d8")
	var shadow := StyleBoxFlat.new(); shadow.bg_color = Color(0, 0, 0, 0.46); shadow.set_corner_radius_all(32); draw_style_box(shadow, panel_rect.grow_side(SIDE_BOTTOM, 10).grow_side(SIDE_RIGHT, 7))
	var panel := StyleBoxFlat.new(); panel.bg_color = Color("132844"); panel.border_color = accent; panel.set_border_width_all(3); panel.set_corner_radius_all(32); draw_style_box(panel, panel_rect)
	var sheen := StyleBoxFlat.new(); sheen.bg_color = Color(1, 1, 1, 0.06); sheen.corner_radius_top_left = 29; sheen.corner_radius_top_right = 29; draw_style_box(sheen, Rect2(panel_rect.position + Vector2(4, 4), Vector2(panel_rect.size.x - 8, 115)))
	draw_circle(Vector2(112, 405), 28, Color(accent, 0.16))
	draw_circle(Vector2(112, 405), 17, accent)
	var state_icon := "!" if state == RunStateMachine.State.FAILED else ("✓" if state == RunStateMachine.State.COMPLETED else "Ⅱ")
	draw_string(ThemeDB.fallback_font, Vector2(104, 414), state_icon, HORIZONTAL_ALIGNMENT_CENTER, 16, 18, Color("13213c"))
	var title := "PAUSED"; var subtitle := "Take a breath. The island waits."
	var final_stage: bool = snapshot.get("stage", 1) >= 15
	var body := "Your run is safely frozen. Resume when you are ready."
	if state == RunStateMachine.State.FAILED:
		title = "TRIP INTERRUPTED"
		var parameter := String(snapshot.get("failure_parameter", "your traveler"))
		subtitle = "%s slipped outside the safe zone." % parameter.capitalize()
		body = _failure_advice(parameter)
	elif state == RunStateMachine.State.COMPLETED:
		if final_stage:
			title = "THE GRAND POSTCARD"
			subtitle = "Milo made it home with every need in the green."
			body = "Fifteen islands, countless bad decisions, and one surprisingly responsible tourist."
		else:
			title = "ISLAND CHECKPOINT CLEARED"
			subtitle = "Milo reached the next postcard stop. +%d bonus!" % snapshot.get("bonus", 500)
			body = _completion_advice(snapshot.get("stage", 1))
	var stars: int = mini(3, 1 + int(snapshot.get("correct_decisions", 0) >= 8) + int(snapshot.get("missed_beneficial", 0) == 0))
	var continue_text := "TAP OR PRESS SPACE / ENTER / N FOR THE NEXT ISLAND"
	var action_text := "TAP OR PRESS R TO TRY AGAIN"
	if state == RunStateMachine.State.PAUSED: action_text = "TAP OR SPACE TO RESUME    R TWICE TO RESTART"
	elif state == RunStateMachine.State.COMPLETED: action_text = continue_text if not final_stage else "TAP OR PRESS R FOR A NEW JOURNEY"
	var font := ThemeDB.fallback_font
	draw_string(font, Vector2(150, 395), title, HORIZONTAL_ALIGNMENT_CENTER, 470, 28, Color("fff0bd"))
	draw_string(font, Vector2(120, 452), subtitle, HORIZONTAL_ALIGNMENT_CENTER, 520, 18, Color("a8e5dc"))
	draw_multiline_string(font, Vector2(120, 482), body, HORIZONTAL_ALIGNMENT_CENTER, 520, 16, 2, Color.WHITE)
	draw_line(Vector2(120, 544), Vector2(600, 544), Color(accent, 0.28), 2.0)
	for index in 3:
		_draw_star(Vector2(300 + index * 60, 575), 20, index < stars)
	draw_string(font, Vector2(120, 635), "SCORE  %d" % snapshot["score"], HORIZONTAL_ALIGNMENT_LEFT, -1, 25, Color.WHITE)
	draw_string(font, Vector2(420, 635), "BEST  %d" % snapshot.get("best_score", 0), HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Color("ffe08a"))
	draw_string(font, Vector2(120, 678), "HELPFUL ITEMS  %d     MISSED  %d" % [snapshot.get("beneficial_collected", 0), snapshot.get("missed_beneficial", 0)], HORIZONTAL_ALIGNMENT_LEFT, -1, 15, Color.WHITE)
	draw_string(font, Vector2(120, 710), "HAZARDS PASSED  %d     CUT  %d" % [snapshot.get("hazards_passed", 0), snapshot.get("hazards_cut", 0)], HORIZONTAL_ALIGNMENT_LEFT, -1, 15, Color.WHITE)
	draw_string(font, Vector2(120, 742), "SMART MIXES  %d     MIXED CHOICES  %d" % [snapshot.get("beneficial_tradeoffs", 0), snapshot.get("tradeoffs_taken", 0)], HORIZONTAL_ALIGNMENT_LEFT, -1, 15, Color("a8e5dc"))
	draw_string(font, Vector2(100, 850), action_text, HORIZONTAL_ALIGNMENT_CENTER, 520, 15, Color.WHITE)

func _failure_advice(parameter: String) -> String:
	var advice := {
		"hunger": "The snack clock won this round. Prioritize food items before chasing fun.",
		"rest": "Milo spent his energy like a celebrity on tour. Take pillows and avoid back-to-back late plans.",
		"fun": "Even paradise needs a little joy. Mix practical care with a camera moment.",
		"social": "The postcards cannot applaud. Make room for friends before the island feels lonely.",
		"hygiene": "Mud is a souvenir, not a lifestyle. Plan a soap break before the meter reaches the red.",
	}
	return advice.get(parameter.to_lower(), "One need crossed the safe border. Watch the priority meter and plan one item ahead.")

func _completion_advice(stage: int) -> String:
	var advice := {
		1: "Milo can now recognize food, rest, and fun before they become emergencies.",
		2: "He learned the most important tourist skill: letting suspicious snacks pass.",
		3: "The island taught him that good items can still be bad when taken too close together.",
		6: "Neon Harbor is listening. Social care is now part of every travel plan.",
		11: "Serene Country made one thing clear: clean socks are strategic equipment.",
	}
	return advice.get(stage, "A calm plan beat frantic tapping. Carry that rhythm to the next island.")

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
