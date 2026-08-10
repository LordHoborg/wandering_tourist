class_name SpawnBagGenerator
extends RefCounted

const ItemDefinition = preload("res://scripts/data/item_definition.gd")
const DeterministicRng = preload("res://scripts/game/deterministic_rng.gd")

func generate(simple_items: Array[ItemDefinition], trade_items: Array[ItemDefinition], rng: DeterministicRng) -> Array[ItemDefinition]:
	assert(simple_items.size() > 0 and trade_items.size() > 0)
	var bag: Array[ItemDefinition] = []
	for index in range(7): bag.append(simple_items[rng.next_index(simple_items.size())])
	for index in range(3): bag.append(trade_items[rng.next_index(trade_items.size())])
	# A bag is only valid if every parameter has at least one positive recovery.
	# Replace simple slots where necessary without changing the 7/3 distribution.
	for parameter_id: StringName in [&"hunger", &"rest", &"fun"]:
		var has_recovery := false
		for item: ItemDefinition in bag:
			if item.deltas.get(parameter_id, 0.0) > 0.0:
				has_recovery = true
				break
		if not has_recovery:
			for replacement: ItemDefinition in simple_items:
				if replacement.deltas.get(parameter_id, 0.0) > 0.0:
					for bag_index in range(7):
						bag[bag_index] = replacement
						break
					break
	for index in range(bag.size()):
		var swap_index: int = rng.next_index(bag.size())
		var item := bag[index]; bag[index] = bag[swap_index]; bag[swap_index] = item
	return bag
