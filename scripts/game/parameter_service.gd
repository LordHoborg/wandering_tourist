class_name ParameterService
extends RefCounted

var definitions: Array[ParameterDefinition]
var state := ParameterState.new()

func _init(parameter_definitions: Array[ParameterDefinition]) -> void:
	definitions = parameter_definitions
	state.set_defaults(definitions)

func tick(delta: float, active_ids: Array[StringName] = []) -> bool:
	for definition: ParameterDefinition in definitions:
		if not active_ids.is_empty() and not active_ids.has(definition.id):
			continue
		state.values[definition.id] += definition.decay_per_second * delta
	return is_safe(active_ids)

func apply(deltas: Dictionary[StringName, float]) -> bool:
	state.apply(deltas)
	return is_safe()

func is_safe(active_ids: Array[StringName] = []) -> bool:
	for definition: ParameterDefinition in definitions:
		if not active_ids.is_empty() and not active_ids.has(definition.id):
			continue
		var value := state.values[definition.id]
		if value < definition.safe_min or value > definition.safe_max:
			return false
	return true

func unsafe_parameter_id(active_ids: Array[StringName] = []) -> StringName:
	for definition: ParameterDefinition in definitions:
		if not active_ids.is_empty() and not active_ids.has(definition.id):
			continue
		var value := state.values[definition.id]
		if value < definition.safe_min or value > definition.safe_max:
			return definition.id
	return &""
