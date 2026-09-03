class_name StageBriefing
extends Control

const Backdrop = preload("res://scripts/ui/tropical_backdrop.gd")

signal dismissed

const STORIES: Array[Dictionary] = [
	{"title": "THE TOURIST WHO FORGOT HIMSELF", "lines": ["Meet Milo: collector of island postcards, professional loser of water bottles.", "He could name every beach, but sometimes forgot lunch existed.", "Your job is simple: keep Milo alive long enough to enjoy the view."], "tip": "CUT helpful items at the electric line."},
	{"title": "THE GREAT FRUIT DISCOVERY", "lines": ["Milo learned that sightseeing on an empty stomach turns temples into giant sandwiches.", "Fruit raises Hunger. Stale snacks are less romantic than they look.", "Take useful food; let suspicious food continue its lonely journey."], "tip": "Hunger falls fastest. Watch it first."},
	{"title": "COFFEE IS NOT A BED", "lines": ["Milo tried replacing sleep with coffee. The coffee was delighted. Milo was not.", "Pillows restore Rest, while alarm clocks deserve to pass untouched.", "Two coffees too quickly create a DOUBLE COFFEE penalty."], "tip": "After coffee, wait before taking another."},
	{"title": "A CAMERA CANNOT FIX BOREDOM FOREVER", "lines": ["Milo photographed the same palm tree forty-seven times.", "Camera moments restore Fun. Rain clouds lower it if you cut them.", "A full meal followed immediately by the night market becomes TOO MUCH FOOD."], "tip": "Read the item label before every cut."},
	{"title": "THE FIRST ISLAND EXAM", "lines": ["Three needs, two lanes, one tourist with questionable judgment.", "Keep values between 20 and 80. Too little is bad; too much is also bad.", "The weakest meter is marked as PRIORITY."], "tip": "Balance beats collecting everything."},
	{"title": "WELCOME TO NEON HARBOR", "lines": ["Milo arrived in a city where strangers became friends before he learned their names.", "SOCIAL is now active because travel is less fun when nobody hears the stories.", "Friends restore Social. Awkward meetings are allowed to walk away."], "tip": "A fourth meter joins the routine."},
	{"title": "THE 6 A.M. GROUP TOUR", "lines": ["Milo booked a dawn tour directly after a midnight market.", "His new friends were impressed by how loudly he yawned.", "Night Market followed quickly by Group Tour triggers NO SLEEP TOUR."], "tip": "Some good items form bad sequences."},
	{"title": "POPULAR, TIRED, STILL SMILING", "lines": ["Social plans can repair loneliness while quietly stealing Rest.", "Purple MIXED cards are not automatic yes-or-no choices.", "Take them only when their combined effect moves your needs toward safety."], "tip": "GOOD CHOICE depends on your current meters."},
	{"title": "THE WARNING CHOIR", "lines": ["Milo's needs now complain at different rhythms.", "Hunger shouts first. Rest grumbles later. Social and Hygiene are patient.", "A warning pulse means the safe border is getting close."], "tip": "React to the cause, not just the sound."},
	{"title": "LAST NIGHT IN THE CITY", "lines": ["Milo finally learned to leave one invitation unanswered.", "Momentum rewards a chain of smart decisions, not frantic tapping.", "Missed helpful items hurt momentum, but reckless cuts hurt more."], "tip": "Timing and restraint build Travel Spirit."},
	{"title": "WELCOME TO SERENE COUNTRY", "lines": ["Milo traded neon streets for muddy paths and immediately stepped in every puddle.", "HYGIENE is now active. Soap helps; muddy shoes should keep falling.", "Five needs do not decay equally, so priorities will keep changing."], "tip": "The fifth meter joins at level 11."},
	{"title": "TOO MANY PEOPLE, NOT ENOUGH SHOWER", "lines": ["Milo scheduled a group tour and a street festival back-to-back.", "The crowd was wonderful. His Rest and Hygiene filed formal complaints.", "Group Tour followed quickly by Street Festival triggers CROWD OVERLOAD."], "tip": "WAIT when an item card warns about a combo."},
	{"title": "THE FIVE-METER WALTZ", "lines": ["Hunger moves quickly, Rest follows, Fun wanders, Social strolls, Hygiene takes its time.", "Fast meters need frequent small care. Slow meters need occasional deliberate care.", "Do not waste a rare item just because it is available."], "tip": "Match your decisions to each need's rhythm."},
	{"title": "MILO ALMOST LOOKS RESPONSIBLE", "lines": ["He now eats, sleeps, laughs, talks, and occasionally remembers soap.", "The islands speed up, but the rules remain readable.", "Use the PRIORITY meter, sequence warnings, and cut-window pulse together."], "tip": "Plan one item ahead."},
	{"title": "THE POSTCARD HOME", "lines": ["Milo has crossed beaches, cities, fields, ruins, and crystal shores.", "He still loses his hat, but he no longer loses himself.", "Finish the journey by making calm choices when every meter wants attention."], "tip": "The best tourist returns with stories—and all five needs safe."},
]

var theme_id: StringName = &"tropical"
var _shown_at := 0.0
var _line_nodes: Array[Label] = []
var _continue_button: Button

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	_continue_button = Button.new()
	_continue_button.text = "CONTINUE THE STORY"
	_continue_button.position = Vector2(200, 1050)
	_continue_button.size = Vector2(320, 72)
	_continue_button.add_theme_font_size_override("font_size", 20)
	_continue_button.pressed.connect(_dismiss)
	add_child(_continue_button)
	hide()

func show_stage(stage_number: int, stage_title: String, next_theme: StringName) -> void:
	theme_id = next_theme
	_shown_at = Time.get_ticks_msec() / 1000.0
	for node in _line_nodes:
		node.queue_free()
	_line_nodes.clear()
	var story: Dictionary = STORIES[clampi(stage_number - 1, 0, STORIES.size() - 1)]
	_add_line("CHAPTER %02d  ·  %s" % [stage_number, stage_title], 70, 160, 580, 34, Color("8ce4d8"), 0.0)
	_add_line(story["title"], 70, 225, 580, 30, Color("fff0bd"), 0.12)
	var y := 340.0
	for line: String in story["lines"]:
		_add_line(line, 80, y, 560, 22, Color.WHITE, 0.28 + _line_nodes.size() * 0.10)
		y += 145.0
	_add_line("TRAVEL TIP  •  %s" % story["tip"], 80, 850, 560, 20, Color("ffe08a"), 0.82)
	_continue_button.modulate.a = 0.0
	_continue_button.disabled = true
	_continue_button.show()
	var button_tween := create_tween()
	button_tween.tween_interval(1.15)
	button_tween.tween_property(_continue_button, "modulate:a", 1.0, 0.25)
	button_tween.tween_callback(func() -> void: _continue_button.disabled = false)
	show()
	queue_redraw()

func _add_line(text: String, x: float, target_y: float, width: float, font_size: int, color: Color, delay: float) -> void:
	var label := Label.new()
	label.text = text
	label.position = Vector2(x, -120.0)
	label.size = Vector2(width, 120)
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	label.add_theme_color_override("font_shadow_color", Color(0.01, 0.03, 0.08, 0.9))
	label.add_theme_constant_override("shadow_offset_x", 2)
	label.add_theme_constant_override("shadow_offset_y", 3)
	add_child(label)
	_line_nodes.append(label)
	if _reduced_motion():
		label.position = Vector2(x, target_y)
		return
	var tween := create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_interval(delay)
	tween.tween_property(label, "position", Vector2(x, target_y), 0.55)

func _process(_delta: float) -> void:
	if visible:
		queue_redraw()

func _unhandled_input(event: InputEvent) -> void:
	if visible and event.is_action_pressed("ui_accept") and not _continue_button.disabled:
		_dismiss()

func _dismiss() -> void:
	if not visible or Time.get_ticks_msec() / 1000.0 - _shown_at < 0.8:
		return
	hide()
	dismissed.emit()

func _draw() -> void:
	if not visible:
		return
	var reduced_motion := _reduced_motion()
	var t := 0.0 if reduced_motion else Time.get_ticks_msec() / 1000.0
	Backdrop.draw(self, size, t, reduced_motion, theme_id)
	draw_rect(Rect2(Vector2.ZERO, size), Color(0.01, 0.03, 0.10, 0.72))
	var panel := StyleBoxFlat.new()
	panel.bg_color = Color(0.04, 0.09, 0.19, 0.93)
	panel.border_color = Color("f5cf72")
	panel.set_border_width_all(2)
	panel.set_corner_radius_all(28)
	panel.shadow_color = Color(0, 0, 0, 0.45)
	panel.shadow_size = 10
	draw_style_box(panel, Rect2(40, 120, size.x - 80, 850))

func _reduced_motion() -> bool:
	var settings := get_node_or_null("/root/AppSettings")
	return settings != null and bool(settings.get("reduced_motion"))
