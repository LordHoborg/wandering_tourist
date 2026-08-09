class_name ParameterState
extends RefCounted

var values: Dictionary[StringName, float] = {}

func set_defaults(definitions: Array[ParameterDefinition]) -> void:
	values.clear()
	for definition: ParameterDefinition in definitions:
		values[definition.id] = definition.start_value

func apply(deltas: Dictionary[StringName, float]) -> void:
	for id: StringName in deltas:
		values[id] = values.get(id, 0.0) + deltas[id]
