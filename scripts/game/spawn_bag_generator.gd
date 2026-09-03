class_name SpawnBagGenerator
extends RefCounted

const ItemDefinition = preload("res://scripts/data/item_definition.gd")
const DeterministicRng = preload("res://scripts/game/deterministic_rng.gd")

func generate(simple_items: Array[ItemDefinition], trade_items: Array[ItemDefinition], rng: DeterministicRng, simple_count: int = 7, trade_count: int = 3, parameter_ids: Array[StringName] = [&"hunger", &"rest", &"fun"]) -> Array[ItemDefinition]:
	assert(simple_count == 0 or simple_items.size() > 0)
	assert(trade_count == 0 or trade_items.size() > 0)
	var bag: Array[ItemDefinition] = []
	var recovery_items: Dictionary[StringName, Array] = {}
	for parameter_id: StringName in parameter_ids:
		recovery_items[parameter_id] = []
		for item: ItemDefinition in simple_items:
			if item.deltas.get(parameter_id, 0.0) > 0.0:
				recovery_items[parameter_id].append(item)
	var recovery_slots := mini(simple_count, maxi(parameter_ids.size(), simple_count - 2))
	for parameter_id: StringName in parameter_ids:
		if bag.size() >= recovery_slots:
			break
		var options: Array = recovery_items.get(parameter_id, [])
		if not options.is_empty():
			bag.append(options[rng.next_index(options.size())])
	while bag.size() < recovery_slots:
		var parameter_id: StringName = parameter_ids[rng.next_index(parameter_ids.size())]
		var options: Array = recovery_items.get(parameter_id, [])
		if not options.is_empty():
			bag.append(options[rng.next_index(options.size())])
		else:
			bag.append(simple_items[rng.next_index(simple_items.size())])
	while bag.size() < simple_count:
		bag.append(simple_items[rng.next_index(simple_items.size())])
	for index in range(trade_count): bag.append(trade_items[rng.next_index(trade_items.size())])
	# A bag is only valid if every parameter has at least one positive recovery.
	# Replace simple slots where necessary without changing the 7/3 distribution.
	var replaced_slots: Dictionary[int, bool] = {}
	for parameter_id: StringName in parameter_ids:
		var has_recovery := false
		for item: ItemDefinition in bag:
			if item.deltas.get(parameter_id, 0.0) > 0.0:
				has_recovery = true
				break
		if not has_recovery:
			for replacement: ItemDefinition in simple_items:
				if replacement.deltas.get(parameter_id, 0.0) > 0.0:
					for bag_index in range(simple_count):
						if not replaced_slots.has(bag_index):
							bag[bag_index] = replacement
							replaced_slots[bag_index] = true
							break
					break
	for index in range(bag.size()):
		var swap_index: int = rng.next_index(bag.size())
		var item := bag[index]; bag[index] = bag[swap_index]; bag[swap_index] = item
	return bag
