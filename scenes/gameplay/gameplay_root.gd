extends Control

const Definition = preload("res://scripts/data/parameter_definition.gd")
const Coordinator = preload("res://scripts/game/gameplay_coordinator.gd")
const InputAdapter = preload("res://scripts/game/lane_input_adapter.gd")

var game: GameplayCoordinator
var input_adapter: LaneInputAdapter
var snapshot: Dictionary = {}
var item_views: Array[ColorRect] = []

@onready var info: Label = $Info
@onready var result: Label = $Result
@onready var item_layer: Control = $ItemLayer

func _ready() -> void:
	var definitions: Array[ParameterDefinition] = []
	for id in [&"hunger", &"rest", &"fun"]:
		var definition: ParameterDefinition = Definition.new()
		definition.id = id
		definitions.append(definition)
	game = Coordinator.new(definitions, 120.0, "user://best_score.dat")
	game.snapshot_published.connect(_render_snapshot)
	input_adapter = InputAdapter.new()
	input_adapter.lane_activated.connect(game.handle_lane_intent)
	game.start()

func _process(delta: float) -> void:
	game.tick(delta)

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		input_adapter.activate_from_pointer(0 if event.position.x < size.x * 0.5 else 1)
	elif event is InputEventScreenTouch and event.pressed:
		input_adapter.activate_from_pointer(0 if event.position.x < size.x * 0.5 else 1)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		if snapshot.get("state") == RunStateMachine.State.RUNNING:
			game.pause_intent()
		elif snapshot.get("state") == RunStateMachine.State.PAUSED:
			game.resume()
	elif event.is_key_pressed(KEY_R):
		game.restart()

func _render_snapshot(next_snapshot: Dictionary) -> void:
	snapshot = next_snapshot
	var values: Dictionary = snapshot["parameters"]
	info.text = "Hunger %.1f   Rest %.1f   Fun %.1f\nTime %.1f   Score %d   Best %d\nClick/tap a lane in the final 0.60 seconds\nSpace: Pause/Resume   R: Restart" % [values[&"hunger"], values[&"rest"], values[&"fun"], snapshot["remaining"], snapshot["score"], snapshot["best_score"]]
	match snapshot["state"]:
		RunStateMachine.State.PAUSED: result.text = "PAUSED"
		RunStateMachine.State.FAILED: result.text = "FAILED - Press R"
		RunStateMachine.State.COMPLETED: result.text = "COMPLETED - Press R"
		_: result.text = ""
	for view in item_views:
		view.queue_free()
	item_views.clear()
	for item: Dictionary in snapshot["items"]:
		var view := ColorRect.new()
		var lane: int = item["lane"]
		var progress: float = item["progress"]
		view.position = Vector2(130.0 if lane == 0 else 490.0, 160.0 + progress * 760.0)
		view.size = Vector2(100.0, 70.0)
		if item["tradeoff"]:
			view.color = Color(0.75, 0.3, 0.95)
		elif item["collect"]:
			view.color = Color(0.2, 0.9, 0.3)
		else:
			view.color = Color(0.95, 0.25, 0.2)
		item_layer.add_child(view)
		item_views.append(view)
