extends SceneTree
const Definition = preload("res://scripts/data/parameter_definition.gd")
const Coordinator = preload("res://scripts/game/gameplay_coordinator.gd")
var passed := 0
var failed := 0
func _init() -> void:
	print("TEST START")
	DirAccess.remove_absolute(ProjectSettings.globalize_path("user://coordinator_test.dat"))
	var defs: Array[ParameterDefinition] = []
	for id in [&"hunger", &"rest", &"fun"]:
		var definition: ParameterDefinition = Definition.new(); definition.id = id; defs.append(definition)
	var game = Coordinator.new(defs, 120.0, "user://coordinator_test.dat")
	_check(game.state_machine.state == RunStateMachine.State.IDLE, "initial IDLE")
	_check(game.start(), "start running")
	game.tick(1.0); _check(game.timer.elapsed == 1.0 and game.parameters.state.values[&"hunger"] < 50.0, "timer and decay running")
	_check(game.pause_intent(), "pause transition"); var elapsed: float = game.timer.elapsed; var hunger: float = game.parameters.state.values[&"hunger"]; game.tick(3.0)
	_check(game.timer.elapsed == elapsed and game.parameters.state.values[&"hunger"] == hunger, "pause freeze")
	_check(game.resume(), "resume transition")
	# Neutralize passive decay so an idle run reaches the stage timer's end
	# instead of failing on parameter drain; this isolates the timer path.
	for definition: ParameterDefinition in game.parameters.definitions:
		definition.decay_per_second = 0.0
	for index in range(2000):
		game.tick(0.1)
		if game.state_machine.state != RunStateMachine.State.RUNNING:
			break
	_check(game.state_machine.state == RunStateMachine.State.COMPLETED and game.score.score == game.level.completion_bonus, "full stage timer completes with bonus")
	_check(game.best_scores.best_score == game.level.completion_bonus, "valid final result updates best score")
	var repeat = Coordinator.new(defs, 120.0, "user://coordinator_test.dat")
	_check(repeat.best_scores.best_score == game.level.completion_bonus and not repeat.best_scores.submit(game.level.completion_bonus), "lower equal score does not replace best")
	var failing = Coordinator.new(defs, 120.0, "user://coordinator_failure.dat")
	var failure_delta: Dictionary[StringName, float] = {}; failure_delta[&"hunger"] = -31.0
	failing.start(); failing.parameters.apply(failure_delta); failing.tick(0.01)
	_check(failing.state_machine.state == RunStateMachine.State.FAILED, "out of range transition failed")
	var first = Coordinator.new(defs, 120.0, "user://deterministic_one.dat"); var second = Coordinator.new(defs, 120.0, "user://deterministic_two.dat")
	first.start(); second.start()
	for index in range(2000):
		first.tick(0.1); second.tick(0.1)
	_check(first.score.score == second.score.score and first.state_machine.state == second.state_machine.state, "deterministic headless run")
	print("TESTS PASSED: %d" % passed); print("TESTS FAILED: %d" % failed); quit(0 if failed == 0 else 1)
func _check(value: bool, name: String) -> void:
	if value: passed += 1; print("PASS: %s" % name)
	else: failed += 1; push_error("FAIL: %s" % name)
