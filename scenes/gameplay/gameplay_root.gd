extends Control

const Definition = preload("res://scripts/data/parameter_definition.gd")
const Coordinator = preload("res://scripts/game/gameplay_coordinator.gd")
const InputAdapter = preload("res://scripts/game/lane_input_adapter.gd")
const ItemView = preload("res://scripts/ui/travel_item_view.gd")

const LANE_TOP := 300.0
const LANE_HEIGHT := 680.0
const ITEM_SIZE := Vector2(146, 94)

signal audio_cue_requested(cue: StringName)

var game: GameplayCoordinator
var input_adapter: LaneInputAdapter
var snapshot: Dictionary = {}
var item_views: Dictionary = {}
var event_kinds: Dictionary = {}
var hint_seen := false

@onready var playfield: TravelPlayfield = $Playfield
@onready var hud: TravelHud = $Hud
@onready var item_layer: Control = $ItemLayer
@onready var feedback: TravelFeedbackLayer = $Feedback
@onready var overlay: TravelOverlay = $Overlay
@onready var hint: Label = $Hint

func _ready() -> void:
	var definitions: Array[ParameterDefinition] = []
	for id in [&"hunger", &"rest", &"fun"]:
		var definition: ParameterDefinition = Definition.new()
		definition.id = id
		definitions.append(definition)
	game = Coordinator.new(definitions, 120.0, "user://best_score.dat")
	game.snapshot_published.connect(_render_snapshot)
	game.presentation_event.connect(_on_presentation_event)
	input_adapter = InputAdapter.new()
	input_adapter.lane_activated.connect(game.handle_lane_intent)
	game.start()
	if not AppSettings.reduced_motion:
		var tween := create_tween()
		tween.tween_interval(5.0)
		tween.tween_property(hint, "modulate:a", 0.0, 0.45)

func _process(delta: float) -> void:
	game.tick(delta)

func _input(event: InputEvent) -> void:
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
	if event.is_action_pressed("ui_accept"):
		if snapshot.get("state") == RunStateMachine.State.RUNNING:
			game.pause_intent()
		elif snapshot.get("state") == RunStateMachine.State.PAUSED:
			game.resume()
	elif event is InputEventKey and event.pressed and event.keycode == KEY_R and not event.echo:
		game.restart()

func _render_snapshot(next_snapshot: Dictionary) -> void:
	snapshot = next_snapshot
	hud.set_snapshot(snapshot)
	overlay.set_snapshot(snapshot)
	var ready := [false, false]
	var live_ids: Dictionary = {}
	for item: Dictionary in snapshot["items"]:
		var instance_id: int = item["instance_id"]
		live_ids[instance_id] = true
		if item["cut_ready"]:
			ready[item["lane"]] = true
		var view: TravelItemView
		if item_views.has(instance_id):
			view = item_views[instance_id]
		else:
			view = ItemView.new()
			view.size = ITEM_SIZE
			view.mouse_filter = Control.MOUSE_FILTER_IGNORE
			item_layer.add_child(view)
			item_views[instance_id] = view
			view.play_spawn(AppSettings.reduced_motion)
		view.configure(item)
		view.position = Vector2(117.0 if item["lane"] == 0 else 457.0, LANE_TOP + item["progress"] * LANE_HEIGHT - ITEM_SIZE.y * 0.5)
	for instance_id in item_views.keys():
		if not live_ids.has(instance_id):
			var removed: TravelItemView = item_views[instance_id]
			removed.play_departure(event_kinds.get(instance_id, "") == &"harmful_cut", AppSettings.reduced_motion)
			item_views.erase(instance_id)
			event_kinds.erase(instance_id)
	playfield.set_cut_ready(ready[0], ready[1])

func _on_presentation_event(kind: StringName, data: Dictionary) -> void:
	_emit_audio_hook(kind)
	var lane: int = data.get("lane", 0)
	var at := Vector2(110.0 if lane == 0 else 450.0, 840.0)
	if kind == &"cut_success":
		feedback.show_feedback("NICE!  +%d  %s" % [data.get("score_delta", 0), _delta_text(data)], Color("fff0a6"), at)
		_mark_item_event(data, kind)
	elif kind == &"harmful_cut":
		feedback.show_feedback("OOPS!  %s" % _delta_text(data), Color("ff9b89"), at)
		_mark_item_event(data, kind)
	elif kind == &"hazard_passed":
		feedback.show_feedback("GOOD!  +%d" % data.get("score_delta", 50), Color("a7f1ca"), at)
	elif kind == &"spawn" and not hint_seen:
		hint_seen = true
		hint.visible = true

func _mark_item_event(data: Dictionary, kind: StringName) -> void:
	# The corresponding presentation node is removed by the next snapshot.
	# Remember the visual treatment keyed by its stable runtime instance ID.
	var instance_id: int = data.get("instance_id", 0)
	if instance_id != 0:
		event_kinds[instance_id] = kind

func _delta_text(data: Dictionary) -> String:
	var chunks: Array[String] = []
	var names := {&"hunger": "H", &"rest": "R", &"fun": "F"}
	for parameter_id in data.get("deltas", {}):
		var amount: float = data["deltas"][parameter_id]
		chunks.append("%+d %s" % [int(amount), names.get(parameter_id, "?")])
	return " ".join(chunks)

func _emit_audio_hook(kind: StringName) -> void:
	if not AppSettings.muted and AppSettings.sfx_volume > 0.0:
		audio_cue_requested.emit(kind)
