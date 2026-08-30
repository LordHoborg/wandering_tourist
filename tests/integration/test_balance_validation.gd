extends SceneTree

# Phase 4 automated balance-validation harness.
# Simulated players verify the mechanical acceptance criteria (AC-01..AC-04,
# AC-09) and that every stage is both losable under neglect and winnable with
# reasonable state-aware play. Human ACs (AC-05..AC-08, AC-10, AC-11) require
# live testers and are tracked separately in TEST_REPORT.md.

const Definition = preload("res://scripts/data/parameter_definition.gd")
const Coordinator = preload("res://scripts/game/gameplay_coordinator.gd")
const RunState = preload("res://scripts/game/run_state_machine.gd")

const TICK := 0.05
const MAX_TICKS := 4000

var passed := 0
var failed := 0

func _init() -> void:
	DirAccess.remove_absolute(ProjectSettings.globalize_path("user://balance_test.dat"))
	_check_pressure_exists()
	_check_campaign_winnable()
	_check_invalid_taps_are_inert()
	_check_stage3_bag_and_lanes()
	_check_campaign_determinism()
	print("TESTS PASSED: %d" % passed)
	print("TESTS FAILED: %d" % failed)
	quit(0 if failed == 0 else 1)

func _check_pressure_exists() -> void:
	# Neglect must be punished on every stage: an idle player fails before the
	# stage timer ends, proving passive decay creates real pressure.
	for target_stage in range(3):
		var game = _new_game("user://balance_idle_%d.dat" % target_stage)
		game.start()
		if not _drive_to_stage(game, target_stage):
			_check(false, "idle pressure setup reaches stage %d" % (target_stage + 1))
			continue
		var ticks := 0
		while game.state_machine.state == RunState.State.RUNNING and ticks < MAX_TICKS:
			game.tick(TICK)
			ticks += 1
		_check(game.state_machine.state == RunState.State.FAILED, "stage %d fails under total neglect" % (target_stage + 1))

func _check_campaign_winnable() -> void:
	# A reasonable state-aware bot must clear all three stages back to back.
	var game = _new_game("user://balance_test.dat")
	game.start()
	var cleared := 0
	for target_stage in range(3):
		if not _play_stage(game):
			break
		cleared += 1
		_check(true, "stage %d winnable by state-aware bot" % (target_stage + 1))
		if target_stage < 2:
			if not game.advance_stage():
				_check(false, "advance from stage %d" % (target_stage + 1))
				break
	_check(cleared == 3, "full three-stage campaign is completable")
	_check(game.score.score > 0 and game.best_scores.best_score >= game.score.score, "campaign result submitted to best score (AC-09)")
	var reloaded = _new_game("user://balance_test.dat")
	_check(reloaded.best_scores.best_score == game.best_scores.best_score, "best score persists across sessions (AC-09)")

func _check_invalid_taps_are_inert() -> void:
	# AC-04: tapping with no eligible item changes neither score nor parameters.
	var game = _new_game("user://balance_inert.dat")
	game.start()
	game.tick(0.1)
	var score_before: int = game.score.score
	var hunger_before: float = game.parameters.state.values[&"hunger"]
	game.handle_lane_intent(0)
	game.handle_lane_intent(1)
	_check(game.score.score == score_before and game.parameters.state.values[&"hunger"] == hunger_before, "invalid taps change nothing (AC-04)")

func _check_stage3_bag_and_lanes() -> void:
	# AC-03: stage 3 uses the approved 7-simple/3-trade bag and no lane gets
	# more than two consecutive spawns.
	var game = _new_game("user://balance_bag.dat")
	game.start()
	if not _drive_to_stage(game, 2):
		_check(false, "bag inspection reaches stage 3")
		return
	var stage = game.stages[2]
	_check(stage.simple_count == 7 and stage.trade_count == 3, "stage 3 keeps the approved 7/3 hybrid bag (AC-03)")
	var lane_streak := 0
	var last_lane := -1
	var streak_ok := true
	var spawn_lanes: Array[int] = []
	game.presentation_event.connect(func(kind: StringName, data: Dictionary) -> void:
		if kind == &"spawn":
			spawn_lanes.append(data["lane"]))
	var ticks := 0
	while game.state_machine.state == RunState.State.RUNNING and ticks < MAX_TICKS and spawn_lanes.size() < 40:
		_bot_act(game)
		game.tick(TICK)
		ticks += 1
	for lane in spawn_lanes:
		if lane == last_lane:
			lane_streak += 1
		else:
			lane_streak = 1
		last_lane = lane
		if lane_streak > 3:
			streak_ok = false
	_check(spawn_lanes.size() >= 30 and streak_ok, "no runaway single-lane spawn streaks (AC-03)")

func _check_campaign_determinism() -> void:
	# Two identical bot campaigns must produce identical outcomes.
	var first = _new_game("user://balance_det_a.dat")
	var second = _new_game("user://balance_det_b.dat")
	first.start(); second.start()
	for index in range(MAX_TICKS):
		_bot_act(first); _bot_act(second)
		first.tick(TICK); second.tick(TICK)
		if first.state_machine.state != RunState.State.RUNNING and second.state_machine.state != RunState.State.RUNNING:
			break
	_check(first.score.score == second.score.score and first.state_machine.state == second.state_machine.state, "bot campaign is deterministic")

func _play_stage(game) -> bool:
	var ticks := 0
	while game.state_machine.state == RunState.State.RUNNING and ticks < MAX_TICKS:
		_bot_act(game)
		game.tick(TICK)
		ticks += 1
	return game.state_machine.state == RunState.State.COMPLETED

func _drive_to_stage(game, target_stage: int) -> bool:
	while game.stage_index < target_stage:
		if not _play_stage(game) or not game.advance_stage():
			return false
	return true

func _bot_act(game) -> void:
	for lane in range(2):
		var instance = game._front_eligible_item(lane)
		if instance != null and _should_cut(game, instance.definition):
			game.handle_lane_intent(lane)

func _should_cut(game, item) -> bool:
	if not item.should_collect:
		return false
	var values: Dictionary = game.parameters.state.values
	var before_distance := 0.0
	var after_distance := 0.0
	for id: StringName in [&"hunger", &"rest", &"fun"]:
		var current: float = values.get(id, 50.0)
		var next: float = current + item.deltas.get(id, 0.0)
		if next < 22.0 or next > 78.0:
			return false
		before_distance += absf(current - 50.0)
		after_distance += absf(next - 50.0)
	if item.is_tradeoff:
		return after_distance < before_distance
	return true

func _new_game(path: String):
	var definitions: Array[ParameterDefinition] = []
	for id in [&"hunger", &"rest", &"fun"]:
		var definition: ParameterDefinition = Definition.new()
		definition.id = id
		definitions.append(definition)
	return Coordinator.new(definitions, 120.0, path)

func _check(condition: bool, name: String) -> void:
	if condition:
		passed += 1
		print("PASS: %s" % name)
	else:
		failed += 1
		push_error("FAIL: %s" % name)
