class_name SpawnFairnessValidator
extends RefCounted

var drought: Dictionary[StringName, int] = {&"hunger": 0, &"rest": 0, &"fun": 0}
var max_drought: int
func _init(limit: int = 6) -> void:
	max_drought = limit
func accept(item: ItemDefinition) -> bool:
	for id: StringName in drought:
		if item.deltas.get(id, 0.0) > 0.0:
			drought[id] = 0
		else:
			drought[id] += 1
		if drought[id] > max_drought:
			return false
	return true
