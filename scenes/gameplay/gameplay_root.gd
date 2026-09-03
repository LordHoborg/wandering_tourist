extends Control

const Definition = preload("res://scripts/data/parameter_definition.gd")
const Coordinator = preload("res://scripts/game/gameplay_coordinator.gd")
const InputAdapter = preload("res://scripts/game/lane_input_adapter.gd")
const ItemView = preload("res://scripts/ui/travel_item_view.gd")
const AudioDirector = preload("res://scripts/ui/audio_director.gd")

const LANE_TOP := 300.0
const LANE_HEIGHT := 680.0
const ITEM_SIZE := Vector2(160, 112)
const RESTART_CONFIRM_SECONDS := 3.0

signal audio_cue_requested(cue: StringName)

var game: GameplayCoordinator
var input_adapter: LaneInputAdapter
var audio: AudioDirector
var snapshot: Dictionary = {}
var item_views: Dictionary = {}
var event_kinds: Dictionary = {}
var hint_seen := false
var run_started := false
var restart_armed_at := -1.0

@onready var playfield = $Playfield
@onready var hud = $Hud
@onready var item_layer: Control = $ItemLayer
@onready var feedback = $Feedback
@onready var overlay = $Overlay
@onready var hint: Label = $Hint
@onready var title_screen = $TitleScreen
@onready var pause_button: Button = $PauseButton

func _ready() -> void:
	var definitions: Array[ParameterDefinition] = []
	for id in [&"hunger", &"rest", &"fun", &"social", &"hygiene"]:
		var definition: ParameterDefinition = Definition.new()
		definition.id = id
		definitions.append(definition)
	game = Coordinator.new(definitions, 120.0, "user://best_score.dat")
	game.snapshot_published.connect(_render_snapshot)
	game.presentation_event.connect(_on_presentation_event)
	input_adapter = InputAdapter.new()
	input_adapter.lane_activated.connect(game.handle_lane_intent)
	audio = AudioDirector.new()
	audio.settings = AppSettings
	add_child(audio)
	audio_cue_requested.connect(audio.play_cue)
	hud.warning_cue_requested.connect(audio.play_cue)
	title_screen.set_best_score(game.best_scores.best_score)
	title_screen.start_requested.connect(_start_run)
	overlay.tapped.connect(_on_overlay_tapped)
	pause_button.pressed.connect(_on_pause_pressed)

func _start_run() -> void:
	if run_started:
		return
	run_started = true
	title_screen.hide()
	audio.play_cue(&"ui_start")
	game.start()
	if not AppSettings.reduced_motion:
		var tween := create_tween()
		tween.tween_interval(5.0)
		tween.tween_property(hint, "modulate:a", 0.0, 0.45)

func _process(delta: float) -> void:
	game.tick(delta)

func _input(event: InputEvent) -> void:
	if not run_started:
		return
	if event is InputEventMouseButton and event.pressed:
		_forward_lane_pointer(event.position)
	elif event is InputEventScreenTouch and event.pressed:
		_forward_lane_pointer(event.position)

func _forward_lane_pointer(pointer: Vector2) -> void:
	if pointer.y < LANE_TOP or pointer.y > LANE_TOP + LANE_HEIGHT:
		return
	if pointer.x >= 40.0 and pointer.x <= 340.0:
		input_adapter.activate_from_pointer(0)
	elif pointer.x >= 380.0 and pointer.x <= 680.0:
		input_adapter.activate_from_pointer(1)

func _unhandled_input(event: InputEvent) -> void:
	if not run_started:
		if event.is_action_pressed("ui_accept"):
			_start_run()
		return
	if event.is_action_pressed("ui_accept"):
		if snapshot.get("state") == RunStateMachine.State.RUNNING:
			audio.play_cue(&"ui_pause")
			game.pause_intent()
		elif snapshot.get("state") == RunStateMachine.State.PAUSED:
			audio.play_cue(&"ui_start")
			game.resume()
		elif snapshot.get("state") == RunStateMachine.State.COMPLETED:
			game.advance_stage()
	elif event is InputEventKey and event.pressed and event.keycode == KEY_R and not event.echo:
		_handle_restart_key()
	elif event is InputEventKey and event.pressed and event.keycode == KEY_N and not event.echo:
		game.advance_stage()

func _on_overlay_tapped() -> void:
	var state: int = snapshot.get("state", RunStateMachine.State.IDLE)
	if state == RunStateMachine.State.PAUSED:
		audio.play_cue(&"ui_start")
		game.resume()
	elif state == RunStateMachine.State.FAILED:
		game.restart()
	elif state == RunStateMachine.State.COMPLETED:
		# Non-final stages advance; a completed journey starts a new campaign.
		if not game.advance_stage():
			game.restart_campaign()

func _on_pause_pressed() -> void:
	if snapshot.get("state") == RunStateMachine.State.RUNNING:
		audio.play_cue(&"ui_pause")
		game.pause_intent()

func _handle_restart_key() -> void:
	var state: int = snapshot.get("state", RunStateMachine.State.IDLE)
	if state == RunStateMachine.State.FAILED:
		# Restarting from a result starts a fresh attempt immediately.
		restart_armed_at = -1.0
		game.restart()
	elif state == RunStateMachine.State.COMPLETED:
		restart_armed_at = -1.0
		if snapshot.get("stage", 1) >= 15:
			game.restart_campaign()
		else:
			game.restart()
	elif state == RunStateMachine.State.PAUSED:
		# Restarting from pause requires confirmation: R twice within the window.
		var now := Time.get_ticks_msec() / 1000.0
		if restart_armed_at >= 0.0 and now - restart_armed_at <= RESTART_CONFIRM_SECONDS:
			restart_armed_at = -1.0
			game.restart()
		else:
			restart_armed_at = now
			feedback.show_feedback("PRESS R AGAIN TO CONFIRM RESTART", Color("ffe08a"), Vector2(160.0, 640.0))

func _render_snapshot(next_snapshot: Dictionary) -> void:
	snapshot = next_snapshot
	hud.set_snapshot(snapshot)
	overlay.set_snapshot(snapshot)
	playfield.apply_stage_theme(snapshot.get("theme_id", &"tropical"))
	pause_button.visible = run_started and snapshot.get("state") == RunStateMachine.State.RUNNING
	var ready := [false, false]
	var live_ids: Dictionary = {}
	var sway_time := 0.0 if AppSettings.reduced_motion else Time.get_ticks_msec() / 1000.0
	for item: Dictionary in snapshot["items"]:
		var instance_id: int = item["instance_id"]
		live_ids[instance_id] = true
		if item["cut_ready"]:
			ready[item["lane"]] = true
		var view
		if item_views.has(instance_id):
			view = item_views[instance_id]
		else:
			view = ItemView.new()
			view.size = ITEM_SIZE
			view.pivot_offset = ITEM_SIZE * 0.5
			view.mouse_filter = Control.MOUSE_FILTER_IGNORE
			item_layer.add_child(view)
			item_views[instance_id] = view
			view.play_spawn(AppSettings.reduced_motion)
		view.configure(item)
		var sway := sin(sway_time * 2.2 + float(instance_id % 64) * 1.7) * 7.0
		view.position = Vector2((110.0 if item["lane"] == 0 else 450.0) + sway, LANE_TOP + item["progress"] * LANE_HEIGHT - ITEM_SIZE.y * 0.5)
		view.rotation = sway * 0.008
	for instance_id in item_views.keys():
		if not live_ids.has(instance_id):
			var removed = item_views[instance_id]
			removed.play_departure(event_kinds.get(instance_id, "") == &"harmful_cut", AppSettings.reduced_motion)
			item_views.erase(instance_id)
			event_kinds.erase(instance_id)
	playfield.set_cut_ready(ready[0], ready[1])

func _on_presentation_event(kind: StringName, data: Dictionary) -> void:
	_emit_audio_hook(kind)
	var lane: int = data.get("lane", 0)
	var at := Vector2(110.0 if lane == 0 else 450.0, 840.0)
	if kind == &"cut_success":
		playfield.flash_lane(lane, true)
		playfield.zap_lane(lane)
		feedback.show_feedback("NICE!  +%d  %s" % [data.get("score_delta", 0), _delta_text(data)], Color("fff0a6"), at)
		_mark_item_event(data, kind)
	elif kind == &"harmful_cut":
		playfield.flash_lane(lane, false)
		playfield.zap_lane(lane)
		feedback.show_feedback("OOPS!  %s" % _delta_text(data), Color("ff9b89"), at)
		_mark_item_event(data, kind)
	elif kind == &"hazard_passed":
		playfield.flash_lane(lane, true)
		feedback.show_feedback("GOOD!  +%d" % data.get("score_delta", 50), Color("a7f1ca"), at)
	elif kind == &"beneficial_missed":
		feedback.show_feedback("MISSED %s" % String(data.get("item_id", "ITEM")).to_upper(), Color("ffd38a"), at)
	elif kind == &"spawn" and not hint_seen:
		hint_seen = true
		hint.visible = true
	elif kind == &"stage_started":
		hint.text = "%s\n%s" % [data.get("title", ""), data.get("lesson", "")]
		hint.visible = true
		hint.modulate.a = 1.0
		if not AppSettings.reduced_motion:
			var tween := create_tween()
			tween.tween_interval(4.0)
			tween.tween_property(hint, "modulate:a", 0.0, 0.45)
	elif kind == &"spirit_milestone":
		feedback.show_feedback("SPIRIT TIER %d!" % data.get("tier", 1), Color("ffe08a"), Vector2(225.0, 350.0))
	elif kind == &"cut_window_open":
		var ready_color := Color("9ee8d4") if data.get("collect", true) else Color("ffb18d")
		playfield.arm_lane(lane, data.get("collect", true))
		feedback.show_feedback("NOW  %s" % data.get("decision", "DECIDE"), ready_color, Vector2(130.0 if lane == 0 else 470.0, 805.0))

func _mark_item_event(data: Dictionary, kind: StringName) -> void:
	# The corresponding presentation node is removed by the next snapshot.
	# Remember the visual treatment keyed by its stable runtime instance ID.
	var instance_id: int = data.get("instance_id", 0)
	if instance_id != 0:
		event_kinds[instance_id] = kind

func _delta_text(data: Dictionary) -> String:
	var chunks: Array[String] = []
	var names := {&"hunger": "H", &"rest": "R", &"fun": "F", &"social": "S", &"hygiene": "W"}
	for parameter_id in data.get("deltas", {}):
		var amount: float = data["deltas"][parameter_id]
		chunks.append("%+d %s" % [int(amount), names.get(parameter_id, "?")])
	return " ".join(chunks)

func _emit_audio_hook(kind: StringName) -> void:
	if not AppSettings.muted and AppSettings.sfx_volume > 0.0:
		audio_cue_requested.emit(kind)
