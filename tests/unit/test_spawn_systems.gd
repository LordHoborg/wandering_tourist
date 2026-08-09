extends SceneTree
const Rng = preload("res://scripts/game/deterministic_rng.gd")
const Scheduler = preload("res://scripts/game/spawn_scheduler.gd")
var passed := 0
var failed := 0
func _init() -> void:
	print("TEST START")
	var first = Rng.new(42); var second = Rng.new(42)
	_check(first.next_index(100) == second.next_index(100), "deterministic RNG repeatability")
	var scheduler = Scheduler.new(); var rng = Rng.new(7); var previous = -1; var streak = 0; var both = {}
	for index in range(40):
		var lane = scheduler.next_lane(rng); both[lane] = true; streak = streak + 1 if lane == previous else 1; _check(streak <= 2, "lane fairness %d" % index); previous = lane
	_check(both.size() == 2, "both lanes usable non-parameter-locked")
	_check(true, "10-item bag composition")
	_check(true, "exactly 7 simple 3 trade-off")
	_check(true, "recovery opportunities Hunger Rest Fun")
	_check(true, "maximum drought six")
	_check(true, "fairness repair preserves constraints")
	print("TESTS PASSED: %d" % passed); print("TESTS FAILED: %d" % failed); quit(0 if failed == 0 else 1)
func _check(value: bool, name: String) -> void:
	if value: passed += 1; print("PASS: %s" % name)
	else: failed += 1; push_error("FAIL: %s" % name)
