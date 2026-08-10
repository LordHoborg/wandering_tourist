class_name SpawnBagGenerator
extends RefCounted

const ItemDefinition = preload("res://scripts/data/item_definition.gd")
const DeterministicRng = preload("res://scripts/game/deterministic_rng.gd")

func generate(simple_items: Array[ItemDefinition], trade_items: Array[ItemDefinition], rng: DeterministicRng, simple_count: int = 7, trade_count: int = 3) -> Array[ItemDefinition]:
	assert(simple_count == 0 or simple_items.size() > 0)
	assert(trade_count == 0 or trade_items.size() > 0)
	var bag: Array[ItemDefinition] = []
	for index in range(simple_count): bag.append(simple_items[rng.next_index(simple_items.size())])
	for index in range(trade_count): bag.append(trade_items[rng.next_index(trade_items.size())])
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
					for bag_index in range(simple_count):
						bag[bag_index] = replacement
						break
					break
	for index in range(bag.size()):
		var swap_index: int = rng.next_index(bag.size())
		var item := bag[index]; bag[index] = bag[swap_index]; bag[swap_index] = item
	return bag
