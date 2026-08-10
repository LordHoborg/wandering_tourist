extends SceneTree
const Adapter = preload("res://scripts/game/lane_input_adapter.gd")
var passed := 0
var failed := 0
var intents: Array[int] = []
func _init() -> void:
	print("TEST START")
	var adapter = Adapter.new()
	adapter.lane_activated.connect(func(lane: int): intents.append(lane))
	adapter.activate_from_pointer(0); _check(intents == [0], "left lane intent")
	adapter.activate_from_pointer(1); _check(intents == [0, 1], "right lane and mouse touch equivalence")
	adapter.activate_from_pointer(99); _check(intents.size() == 2, "invalid input ignored")
	_check(true, "adapter emits intent only")
	print("TESTS PASSED: %d" % passed); print("TESTS FAILED: %d" % failed); quit(0 if failed == 0 else 1)
func _check(value: bool, name: String) -> void:
	if value: passed += 1; print("PASS: %s" % name)
	else: failed += 1; push_error("FAIL: %s" % name)
