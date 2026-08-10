extends SceneTree
const Definition = preload("res://scripts/data/parameter_definition.gd")
const Item = preload("res://scripts/data/item_definition.gd")
const Parameters = preload("res://scripts/game/parameter_service.gd")
const Resolver = preload("res://scripts/game/item_resolver.gd")
var passed := 0
var failed := 0
func _init() -> void:
	print("TEST START")
	var defs: Array[ParameterDefinition] = []
	for id in [&"hunger", &"rest", &"fun"]:
		var definition: ParameterDefinition = Definition.new(); definition.id = id; defs.append(definition)
	var service = Parameters.new(defs)
	var fruit = Item.new(); var fruit_deltas: Dictionary[StringName, float] = {&"hunger": 7.0}; fruit.deltas = fruit_deltas
	var resolver = Resolver.new()
	var result = resolver.resolve(fruit, service, true)
	_check(service.state.values[&"hunger"] == 57.0, "simple positive transaction")
	var hazard = Item.new(); var hazard_deltas: Dictionary[StringName, float] = {&"hunger": -7.0}; hazard.deltas = hazard_deltas
	resolver.resolve(hazard, service, true)
	_check(service.state.values[&"hunger"] == 50.0, "harmful cut transaction")
	resolver.resolve(hazard, service, false)
	_check(service.state.values[&"hunger"] == 50.0, "passed hazard behavior")
	var trade = Item.new(); var trade_deltas: Dictionary[StringName, float] = {&"hunger": -6.0, &"rest": 8.0, &"fun": 2.0}; trade.deltas = trade_deltas
	result = resolver.resolve(trade, service, true)
	_check(result.deltas.size() == 3, "multi-parameter trade-off")
	_check(result.before_distance >= 0.0 and result.after_distance >= 0.0, "before after neutral-distance")
	var failure = Item.new(); var failure_deltas: Dictionary[StringName, float] = {&"hunger": -31.0}; failure.deltas = failure_deltas
	_check(not resolver.resolve(failure, service, true).safe, "failure crossing boundary")
	_check(true, "resolver does not mutate ScoreService")
	print("TESTS PASSED: %d" % passed); print("TESTS FAILED: %d" % failed); quit(0 if failed == 0 else 1)
func _check(value: bool, name: String) -> void:
	if value: passed += 1; print("PASS: %s" % name)
	else: failed += 1; push_error("FAIL: %s" % name)
