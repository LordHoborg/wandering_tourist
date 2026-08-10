extends Control

const Definition = preload("res://scripts/data/parameter_definition.gd")
const Coordinator = preload("res://scripts/game/gameplay_coordinator.gd")
const InputAdapter = preload("res://scripts/game/lane_input_adapter.gd")
var game
var input_adapter
var falling_y: Array[float] = [0.0, 120.0]
@onready var info: Label = $Info
@onready var result: Label = $Result
@onready var left_item: ColorRect = $LeftItem
@onready var right_item: ColorRect = $RightItem

func _ready() -> void:
	var definitions: Array[ParameterDefinition] = []
	for id in [&"hunger", &"rest", &"fun"]:
		var definition: ParameterDefinition = Definition.new(); definition.id = id; definitions.append(definition)
	game = Coordinator.new(definitions, 120.0, "user://best_score.dat")
	input_adapter = InputAdapter.new()
	input_adapter.lane_activated.connect(_on_lane_intent)
	game.start()

func _process(delta: float) -> void:
	game.tick(delta)
	for lane in range(2):
		falling_y[lane] = fmod(falling_y[lane] + 180.0 * delta, 720.0)
	left_item.position.y = falling_y[0] + 170.0
	right_item.position.y = falling_y[1] + 170.0
	var values = game.parameters.state.values
	info.text = "Hunger %.1f   Rest %.1f   Fun %.1f\nTime %.1f   Score %d   Best %d\nSpace: Pause/Resume   R: Restart" % [values[&"hunger"], values[&"rest"], values[&"fun"], game.timer.remaining(), game.score.score, game.best_scores.best_score]
	if game.state_machine.state == RunStateMachine.State.FAILED: result.text = "FAILED"
	elif game.state_machine.state == RunStateMachine.State.COMPLETED: result.text = "COMPLETED"
	else: result.text = ""

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		input_adapter.activate_from_pointer(0 if event.position.x < size.x * 0.5 else 1)
	elif event is InputEventScreenTouch and event.pressed:
		input_adapter.activate_from_pointer(0 if event.position.x < size.x * 0.5 else 1)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		if game.state_machine.state == RunStateMachine.State.RUNNING: game.pause_intent()
		elif game.state_machine.state == RunStateMachine.State.PAUSED: game.resume()
	if event.is_key_pressed(KEY_R): get_tree().reload_current_scene()

func _on_lane_intent(lane_id: int) -> void:
	var delta: Dictionary[StringName, float] = {}
	delta[&"hunger" if lane_id == 0 else &"fun"] = 7.0
	game.parameters.apply(delta)
	game.score.add_simple(100)
