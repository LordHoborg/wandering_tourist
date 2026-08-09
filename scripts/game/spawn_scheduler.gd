class_name SpawnScheduler
extends RefCounted

var bag: Array[ItemDefinition] = []
var last_lane: int = -1
var consecutive_lane: int = 0
func set_bag(items: Array[ItemDefinition]) -> void:
	bag = items
func next_lane(rng: DeterministicRng) -> int:
	var lane := rng.next_index(2)
	if lane == last_lane and consecutive_lane >= 2:
		lane = 1 - lane
	consecutive_lane = consecutive_lane + 1 if lane == last_lane else 1
	last_lane = lane
	return lane
