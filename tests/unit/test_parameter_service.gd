extends SceneTree

var passed: int = 0
var failed: int = 0

func _init() -> void:
	print("TEST START")
	_run_tests()
	print("TESTS PASSED: %d" % passed)
	print("TESTS FAILED: %d" % failed)
	quit(0 if failed == 0 else 1)

func _check(condition: bool, name: String) -> void:
	if condition:
		passed += 1
		print("PASS: %s" % name)
	else:
		failed += 1
		push_error("FAIL: %s" % name)

func _definition(id: StringName, start: float = 50.0) -> ParameterDefinition:
	var definition := ParameterDefinition.new()
	definition.id = id
	definition.start_value = start
	return definition

func _run_tests() -> void:
	var hunger := _definition(&"hunger")
	var rest := _definition(&"rest")
	var fun := _definition(&"fun")
	var service := ParameterService.new([hunger, rest, fun])
	_check(service.state.values[&"hunger"] == 50.0 and service.state.values[&"rest"] == 50.0 and service.state.values[&"fun"] == 50.0, "parameter initialization")
	_check(service.apply({&"hunger": -30.0}), "lower inclusive boundary")
	service = ParameterService.new([hunger, rest, fun])
	_check(service.apply({&"hunger": 30.0}), "upper inclusive boundary")
	_check(not service.apply({&"hunger": -60.1}), "below-20 failure")
	service = ParameterService.new([hunger, rest, fun])
	_check(not service.apply({&"hunger": 30.1}), "above-80 failure")
	service = ParameterService.new([hunger, rest, fun])
	_check(is_equal_approx(service.state.values[&"hunger"], 50.0) and service.tick(1.0) and is_equal_approx(service.state.values[&"hunger"], 49.7), "decay behavior")
	_check(service.apply({&"hunger": 1.0, &"rest": -2.0, &"fun": 3.0}) and service.state.values[&"hunger"] > 50.0 and service.state.values[&"rest"] < 50.0 and service.state.values[&"fun"] > 50.0, "multiple parameter deltas")
	var machine := RunStateMachine.new()
	_check(machine.transition(RunStateMachine.State.RUNNING) and machine.transition(RunStateMachine.State.PAUSED) and machine.transition(RunStateMachine.State.RUNNING) and machine.transition(RunStateMachine.State.COMPLETED) and machine.transition(RunStateMachine.State.IDLE), "legal state transitions")
	machine = RunStateMachine.new()
	_check(not machine.transition(RunStateMachine.State.PAUSED) and not machine.transition(RunStateMachine.State.COMPLETED), "illegal state transitions")
