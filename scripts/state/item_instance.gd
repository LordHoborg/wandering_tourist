class_name ItemInstance
extends RefCounted

var definition: ItemDefinition
var lane_id: int
var spawn_time: float
var resolved: bool = false
var cut_window_announced: bool = false

func _init(item_definition: ItemDefinition, lane: int, created_at: float) -> void:
	definition = item_definition
	lane_id = lane
	spawn_time = created_at

func age(now: float) -> float:
	return maxf(0.0, now - spawn_time)
