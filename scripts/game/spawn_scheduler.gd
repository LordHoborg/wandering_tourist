class_name SpawnScheduler
extends RefCounted

const DeterministicRng = preload("res://scripts/game/deterministic_rng.gd")
const ItemDefinition = preload("res://scripts/data/item_definition.gd")
const SpawnFairnessValidator = preload("res://scripts/game/spawn_fairness_validator.gd")

var bag: Array[ItemDefinition] = []
var last_lane: int = -1
var consecutive_lane: int = 0
func set_bag(items: Array[ItemDefinition]) -> void:
	bag = items.duplicate()

func take_next(fairness: SpawnFairnessValidator) -> ItemDefinition:
	while not bag.is_empty():
		var candidate: ItemDefinition = bag[0]
		if fairness.accept(candidate):
			bag.pop_front()
			return candidate
		var repaired: ItemDefinition = fairness.repair(candidate, bag)
		if repaired != candidate and fairness.accept(repaired):
			bag.erase(repaired)
			return repaired
		# This candidate cannot meet the existing drought constraint. Remove it
		# so an invalid remainder can never permanently stall the spawn loop.
		bag.pop_front()
	return null
func next_lane(rng: DeterministicRng) -> int:
	var lane: int = rng.next_index(2)
	if lane == last_lane and consecutive_lane >= 2:
		lane = 1 - lane
	consecutive_lane = consecutive_lane + 1 if lane == last_lane else 1
	last_lane = lane
	return lane
