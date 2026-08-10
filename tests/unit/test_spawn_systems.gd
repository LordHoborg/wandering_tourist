extends SceneTree
const Rng = preload("res://scripts/game/deterministic_rng.gd")
const Scheduler = preload("res://scripts/game/spawn_scheduler.gd")
const Generator = preload("res://scripts/game/spawn_bag_generator.gd")
const Validator = preload("res://scripts/game/spawn_fairness_validator.gd")
const Item = preload("res://scripts/data/item_definition.gd")
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
	var simple: Array[ItemDefinition] = []; var trade: Array[ItemDefinition] = []
	for id in [&"hunger", &"rest", &"fun"]:
		var boost: ItemDefinition = Item.new(); boost.deltas = {id: 7.0}; simple.append(boost)
		var contextual: ItemDefinition = Item.new(); contextual.is_tradeoff = true; contextual.deltas = {id: 8.0}; trade.append(contextual)
	var bag = Generator.new().generate(simple, trade, Rng.new(99))
	var trade_count := 0
	for item in bag: if item.is_tradeoff: trade_count += 1
	_check(bag.size() == 10, "10-item bag composition")
	_check(trade_count == 3, "exactly 7 simple 3 trade-off")
	var validator = Validator.new(6)
	_check(validator.has_recovery_for_all(bag), "recovery opportunities Hunger Rest Fun")
	var drought_item = Item.new(); drought_item.deltas = {&"hunger": -1.0}
	for index in range(6): validator.accept(drought_item)
	_check(not validator.accept(drought_item), "maximum drought six")
	_check(validator.repair(drought_item, bag).deltas.get(&"hunger", 0.0) > 0.0, "fairness repair preserves constraints")
	print("TESTS PASSED: %d" % passed); print("TESTS FAILED: %d" % failed); quit(0 if failed == 0 else 1)
func _check(value: bool, name: String) -> void:
	if value: passed += 1; print("PASS: %s" % name)
	else: failed += 1; push_error("FAIL: %s" % name)
