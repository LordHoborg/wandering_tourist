class_name ItemResolver
extends RefCounted

class Transaction:
	var before_distance: float
	var after_distance: float
	var safe: bool
	var deltas: Dictionary[StringName, float]

func resolve(item: ItemDefinition, parameters: ParameterService, collected: bool, neutral_target: float = 50.0) -> Transaction:
	var result := Transaction.new()
	var transaction_deltas: Dictionary[StringName, float] = {}
	if collected:
		for parameter_id: StringName in item.deltas:
			transaction_deltas[parameter_id] = item.deltas[parameter_id]
	result.deltas = transaction_deltas
	result.before_distance = _distance(parameters.state.values, neutral_target, parameters.definitions)
	result.safe = parameters.apply(result.deltas) if collected else parameters.is_safe()
	result.after_distance = _distance(parameters.state.values, neutral_target, parameters.definitions)
	return result

func _distance(values: Dictionary[StringName, float], target: float, definitions: Array[ParameterDefinition]) -> float:
	var total := 0.0
	for definition: ParameterDefinition in definitions:
		total += absf(values.get(definition.id, target) - target)
	return total
