class_name SpawnFairnessValidator
extends RefCounted

var drought: Dictionary[StringName, int] = {&"hunger": 0, &"rest": 0, &"fun": 0}
var max_drought: int
func _init(limit: int = 6) -> void:
	max_drought = limit
func accept(item: ItemDefinition) -> bool:
	var next_drought: Dictionary[StringName, int] = {}
	for id: StringName in drought:
		if item.deltas.get(id, 0.0) > 0.0:
			next_drought[id] = 0
		else:
			next_drought[id] = drought[id] + 1
		if next_drought[id] > max_drought:
			return false
	drought = next_drought
	return true

func has_recovery_for_all(items: Array[ItemDefinition]) -> bool:
	for id: StringName in drought:
		var found := false
		for item: ItemDefinition in items:
			if item.deltas.get(id, 0.0) > 0.0: found = true; break
		if not found: return false
	return true

func repair(candidate: ItemDefinition, items: Array[ItemDefinition]) -> ItemDefinition:
	for replacement: ItemDefinition in items:
		if replacement != candidate and _would_accept(replacement): return replacement
	return candidate

func _would_accept(item: ItemDefinition) -> bool:
	for id: StringName in drought:
		if item.deltas.get(id, 0.0) <= 0.0 and drought[id] + 1 > max_drought: return false
	return true
