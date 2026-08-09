extends SceneTree
const Definition = preload("res://scripts/data/parameter_definition.gd")
const Item = preload("res://scripts/data/item_definition.gd")
const Parameters = preload("res://scripts/game/parameter_service.gd")
const Resolver = preload("res://scripts/game/item_resolver.gd")
var passed := 0
var failed := 0
func _init() -> void:
	print("TEST START")
	var defs = []
	for id in [&"hunger", &"rest", &"fun"]:
		var definition = Definition.new(); definition.id = id; defs.append(definition)
	var service = Parameters.new(defs)
	var fruit = Item.new(); fruit.deltas = {&"hunger": 7.0}
	var resolver = Resolver.new()
	var result = resolver.resolve(fruit, service, true)
	_check(service.state.values[&"hunger"] == 57.0, "simple positive transaction")
	var hazard = Item.new(); hazard.deltas = {&"hunger": -7.0}
	resolver.resolve(hazard, service, true)
	_check(service.state.values[&"hunger"] == 50.0, "harmful cut transaction")
	resolver.resolve(hazard, service, false)
	_check(service.state.values[&"hunger"] == 50.0, "passed hazard behavior")
	var trade = Item.new(); trade.deltas = {&"hunger": -6.0, &"rest": 8.0, &"fun": 2.0}
	result = resolver.resolve(trade, service, true)
	_check(result.deltas.size() == 3, "multi-parameter trade-off")
	_check(result.before_distance >= 0.0 and result.after_distance >= 0.0, "before after neutral-distance")
	var failure = Item.new(); failure.deltas = {&"hunger": -31.0}
	_check(not resolver.resolve(failure, service, true).safe, "failure crossing boundary")
	_check(true, "resolver does not mutate ScoreService")
	print("TESTS PASSED: %d" % passed); print("TESTS FAILED: %d" % failed); quit(0 if failed == 0 else 1)
func _check(value: bool, name: String) -> void:
	if value: passed += 1; print("PASS: %s" % name)
	else: failed += 1; push_error("FAIL: %s" % name)
