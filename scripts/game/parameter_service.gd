class_name ParameterService
extends RefCounted

var definitions: Array[ParameterDefinition]
var state := ParameterState.new()

func _init(parameter_definitions: Array[ParameterDefinition]) -> void:
	definitions = parameter_definitions
	state.set_defaults(definitions)

func tick(delta: float) -> bool:
	for definition: ParameterDefinition in definitions:
		state.values[definition.id] += definition.decay_per_second * delta
	return is_safe()

func apply(deltas: Dictionary[StringName, float]) -> bool:
	state.apply(deltas)
	return is_safe()

func is_safe() -> bool:
	for definition: ParameterDefinition in definitions:
		var value := state.values[definition.id]
		if value < definition.safe_min or value > definition.safe_max:
			return false
	return true
