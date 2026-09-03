extends SceneTree

const Definition = preload("res://scripts/data/parameter_definition.gd")
const Coordinator = preload("res://scripts/game/gameplay_coordinator.gd")
const RunState = preload("res://scripts/game/run_state_machine.gd")
const ItemInstance = preload("res://scripts/state/item_instance.gd")

var passed := 0
var failed := 0

func _init() -> void:
	var game = Coordinator.new(_definitions(), 120.0, "user://progression_test.dat")
	_check(game.stages.size() == 15 and game.stages[0].simple_item_ids == [&"fruit", &"pillow", &"camera"] and game.stages[0].trade_count == 0, "15-level campaign starts with essentials")
	_check(game.stages[1].simple_item_ids.has(&"stale_snack") and game.stages[1].trade_count == 0, "level 2 introduces hazards")
	_check(game.stages[2].trade_item_ids.has(&"coffee") and game.stages[2].trade_count == 3, "level 3 introduces trade-offs")
	_check(game.stages[5].active_parameters.has(&"social") and game.stages[5].simple_item_ids.has(&"friend_group"), "level 6 unlocks social needs")
	_check(game.stages[10].active_parameters.has(&"hygiene") and game.stages[10].simple_item_ids.has(&"soap"), "level 11 unlocks hygiene needs")
	_check(game.item_catalog.has(&"street_festival") and game.item_catalog.has(&"spa_day") and game.item_catalog.has(&"group_tour"), "advanced trade-off catalog is complete")
	game.start()
	_check(game._decision_label(game.item_catalog[&"fruit"]) == "COLLECT", "simple item publishes a collect decision")
	_check(game._decision_label(game.item_catalog[&"stale_snack"]) == "LET PASS", "hazard publishes a pass decision")
	game.active_items.clear()
	game.timer.elapsed = game.level.fall_duration - game.level.cut_window * 0.5
	var telegraph := ItemInstance.new(game.item_catalog[&"fruit"], 0, 0.0)
	game.active_items.append(telegraph)
	game.publish_snapshot()
	_check(telegraph.cut_window_announced, "front item announces its cut window")
	game.active_items.clear()
	_check(_survive_stage(game), "reasonable beneficial-collection bot survives stage 1")
	var stage1_total: int = game.score.score
	_check(game.state_machine.state == RunState.State.COMPLETED and game.advance_stage(), "completion advances to stage 2")
	_check(stage1_total > 0 and game.score.score == stage1_total, "campaign score carries into the next stage")
	_check(game.stage_index == 1 and not game.familiarity.has(&"coffee"), "unseen trade-off remains unknown")
	_check(game.stages[1].theme_id == &"sunset_city", "stage 2 keeps its destination theme")
	for index in range(120):
		game.tick(0.1)
		for item in game.active_items.duplicate():
			if item.definition.should_collect and item.age(game.timer.elapsed) >= game.level.fall_duration - game.level.cut_window:
				game.handle_lane_intent(item.lane_id)
		if game.score.score > stage1_total:
			break
	_check(game.score.score > stage1_total, "stage 2 play increases the carried campaign score")
	game.familiarity[&"fruit"] = 5
	game.restart()
	_check(game.score.score == stage1_total and game.score.momentum == 0, "retry rolls back to the stage-entry score")
	_check(game.familiarity.get(&"fruit", 0) == 5 and not game.familiarity.has(&"night_market"), "per-item familiarity persists across retry")
	game.timer.elapsed = game.timer.duration
	game.tick(0.0)
	game.advance_stage()
	_check(game.stage_index == 2 and game.stages[2].destination_id == &"countryside", "level 3 advances with destination data")
	var idle_game = Coordinator.new(_definitions(), 120.0, "user://progression_idle_test.dat")
	idle_game.start()
	idle_game.timer.elapsed = idle_game.timer.duration
	idle_game.tick(0.0)
	idle_game.advance_stage()
	for index in range(900):
		idle_game.tick(0.1)
		if idle_game.state_machine.state == RunState.State.FAILED:
			break
	_check(idle_game.state_machine.state == RunState.State.FAILED and idle_game.stage_index == 1 and not idle_game.advance_stage(), "stage 2 inactivity fails and cannot advance")
	idle_game.restart_campaign()
	_check(idle_game.stage_index == 0 and idle_game.score.score == 0 and idle_game.familiarity.is_empty() and idle_game.state_machine.state == RunState.State.RUNNING, "new journey resets campaign state")
	print("TESTS PASSED: %d" % passed)
	print("TESTS FAILED: %d" % failed)
	quit(0 if failed == 0 else 1)

func _definitions() -> Array[ParameterDefinition]:
	var result: Array[ParameterDefinition] = []
	for id in [&"hunger", &"rest", &"fun", &"social", &"hygiene"]:
		var definition: ParameterDefinition = Definition.new()
		definition.id = id
		result.append(definition)
	return result

func _survive_stage(game) -> bool:
	for index in range(700):
		game.tick(0.1)
		for item in game.active_items.duplicate():
			if item.definition.should_collect and item.age(game.timer.elapsed) >= game.level.fall_duration - game.level.cut_window:
				game.handle_lane_intent(item.lane_id)
		if game.state_machine.state != RunState.State.RUNNING:
			break
	return game.state_machine.state == RunState.State.COMPLETED

func _check(condition: bool, name: String) -> void:
	if condition:
		passed += 1
		print("PASS: %s" % name)
	else:
		failed += 1
		push_error("FAIL: %s" % name)
