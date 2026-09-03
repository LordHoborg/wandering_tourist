class_name GameplayCoordinator
extends RefCounted

const ParameterDefinition = preload("res://scripts/data/parameter_definition.gd")
const ParameterService = preload("res://scripts/game/parameter_service.gd")
const TimerService = preload("res://scripts/game/timer_service.gd")
const ScoreService = preload("res://scripts/game/score_service.gd")
const BestScoreRepository = preload("res://scripts/game/best_score_repository.gd")
const RunStateMachine = preload("res://scripts/game/run_state_machine.gd")
const ItemResolver = preload("res://scripts/game/item_resolver.gd")
const SpawnScheduler = preload("res://scripts/game/spawn_scheduler.gd")
const SpawnFairnessValidator = preload("res://scripts/game/spawn_fairness_validator.gd")
const SpawnBagGenerator = preload("res://scripts/game/spawn_bag_generator.gd")
const DeterministicRng = preload("res://scripts/game/deterministic_rng.gd")
const ItemInstance = preload("res://scripts/state/item_instance.gd")
const StageDefinition = preload("res://scripts/data/stage_definition.gd")

signal snapshot_published(snapshot: Dictionary)
signal presentation_event(kind: StringName, data: Dictionary)

const PARAMETER_DECAY_MULTIPLIERS: Dictionary = {
	&"hunger": 3.0,
	&"rest": 2.15,
	&"fun": 1.55,
	&"social": 0.72,
	&"hygiene": 0.48,
}
const SEQUENCE_RULES: Array[Dictionary] = [
	{"min_level": 3, "previous": &"coffee", "current": &"coffee", "window": 10.0, "label": "DOUBLE COFFEE", "deltas": {&"rest": -12.0, &"fun": -3.0}},
	{"min_level": 4, "previous": &"local_meal", "current": &"night_market", "window": 12.0, "label": "TOO MUCH FOOD", "deltas": {&"hunger": 10.0, &"rest": -5.0}},
	{"min_level": 7, "previous": &"night_market", "current": &"group_tour", "window": 14.0, "label": "NO SLEEP TOUR", "deltas": {&"rest": -11.0, &"social": -3.0}},
	{"min_level": 12, "previous": &"group_tour", "current": &"street_festival", "window": 12.0, "label": "CROWD OVERLOAD", "deltas": {&"rest": -9.0, &"hygiene": -5.0}},
]
var state_machine: RunStateMachine = RunStateMachine.new()
var parameters: ParameterService
var timer: TimerService
var score: ScoreService = ScoreService.new()
var best_scores: BestScoreRepository
var resolver: ItemResolver = ItemResolver.new()
var scheduler: SpawnScheduler = SpawnScheduler.new()
var fairness: SpawnFairnessValidator
var rng: DeterministicRng = DeterministicRng.new(20260810)
var simple_items: Array[ItemDefinition] = []
var trade_items: Array[ItemDefinition] = []
var item_catalog: Dictionary[StringName, ItemDefinition] = {}
var golden_item: ItemDefinition
## Chance that a simple collect spawn in stages 2+ becomes the golden coconut.
var golden_chance := 0.06
var stages: Array[StageDefinition] = []
var stage_index: int = 0
var stage_spawn_count: int = 0
var familiarity: Dictionary[StringName, int] = {}
var correct_decisions: int = 0
var missed_beneficial: int = 0
var harmful_cuts: int = 0
var beneficial_collected: int = 0
var hazards_passed: int = 0
var hazards_cut: int = 0
var tradeoffs_taken: int = 0
var beneficial_tradeoffs: int = 0
var failed_tradeoffs: int = 0
var item_collections: Dictionary[StringName, int] = {}
var item_hazard_passes: Dictionary[StringName, int] = {}
var _last_momentum: int = 0
var active_items: Array[ItemInstance] = []
var spawn_elapsed: float = 0.0
var lane_ready_at: Dictionary[int, float] = {0: 0.0, 1: 0.0}
var level := LevelDefinition.new()
var failure_parameter_id: StringName = &""
## Campaign score accumulated before the current stage started. Advancing
## carries the total forward; retrying a stage rolls back to this baseline so
## a failed attempt cannot be farmed for points.
var stage_entry_score: int = 0
var last_collected_item_id: StringName = &""
var last_collected_at: float = -1000.0

func _init(definitions: Array[ParameterDefinition], duration: float, repository_path: String) -> void:
	_ensure_parameter_definitions(definitions)
	parameters = ParameterService.new(definitions)
	timer = TimerService.new(duration)
	best_scores = BestScoreRepository.new(repository_path)
	level.duration_seconds = duration
	_create_prototype_items()
	_create_stages()
	_apply_stage(0)
	fairness = SpawnFairnessValidator.new(level.max_recovery_drought, _stage().active_parameters)

func _ensure_parameter_definitions(definitions: Array[ParameterDefinition]) -> void:
	var known: Dictionary[StringName, bool] = {}
	for definition: ParameterDefinition in definitions:
		known[definition.id] = true
	for id: StringName in [&"hunger", &"rest", &"fun", &"social", &"hygiene"]:
		if known.has(id):
			continue
		var definition := ParameterDefinition.new()
		definition.id = id
		definitions.append(definition)

func start() -> bool:
	if not state_machine.transition(RunStateMachine.State.RUNNING):
		return false
	_fill_bag()
	presentation_event.emit(&"stage_started", {"stage": stage_index + 1, "title": _stage().title, "lesson": _stage().lesson})
	publish_snapshot()
	return true

func handle_lane_intent(lane_id: int) -> void:
	if state_machine.state != RunStateMachine.State.RUNNING or timer.elapsed < lane_ready_at.get(lane_id, 0.0):
		return
	var instance := _front_eligible_item(lane_id)
	if instance == null:
		return
	lane_ready_at[lane_id] = timer.elapsed + level.lane_cooldown
	var item: ItemDefinition = instance.definition
	var score_before := score.score
	var sequence_rule := _active_sequence_rule(item)
	var modifier_deltas: Dictionary = sequence_rule.get("deltas", {})
	var transaction = resolver.resolve(item, parameters, true, 50.0, modifier_deltas)
	if not sequence_rule.is_empty():
		score.break_momentum()
	elif item.is_tradeoff:
		score.add_tradeoff(transaction.before_distance, transaction.after_distance, not transaction.safe)
		tradeoffs_taken += 1
	elif item.should_collect:
		score.reward_correct(item.score)
		beneficial_collected += 1
		item_collections[item.id] = item_collections.get(item.id, 0) + 1
	else:
		score.break_momentum()
	active_items.erase(instance)
	var score_delta := score.score - score_before
	if item.should_collect:
		last_collected_item_id = item.id
		last_collected_at = timer.elapsed
	var event_data := {"instance_id": instance.get_instance_id(), "item_id": item.id, "lane": lane_id, "score_delta": score_delta, "deltas": transaction.deltas, "safe": transaction.safe, "combo_label": sequence_rule.get("label", "")}
	if not item.should_collect:
		harmful_cuts += 1
		hazards_cut += 1
		presentation_event.emit(&"harmful_cut", event_data)
	elif not sequence_rule.is_empty():
		harmful_cuts += 1
		presentation_event.emit(&"risky_combo", event_data)
	elif transaction.safe:
		if score_delta > 0:
			correct_decisions += 1
			if item.is_tradeoff:
				beneficial_tradeoffs += 1
		elif item.is_tradeoff:
			failed_tradeoffs += 1
		presentation_event.emit(&"cut_success", event_data)
	else:
		harmful_cuts += 1
		presentation_event.emit(&"harmful_cut", event_data)
	if not transaction.safe:
		failure_parameter_id = parameters.unsafe_parameter_id(_stage().active_parameters)
		_finish(RunStateMachine.State.FAILED)
	elif _stage_objective_complete():
		_finish(RunStateMachine.State.COMPLETED)
	_check_spirit_milestone()
	publish_snapshot()

func pause_intent() -> bool:
	if state_machine.state != RunStateMachine.State.RUNNING: return false
	timer.paused = true
	var changed := state_machine.transition(RunStateMachine.State.PAUSED)
	publish_snapshot()
	return changed

func resume() -> bool:
	if state_machine.state != RunStateMachine.State.PAUSED: return false
	timer.paused = false
	var changed := state_machine.transition(RunStateMachine.State.RUNNING)
	publish_snapshot()
	return changed

func tick(delta: float) -> void:
	if state_machine.state != RunStateMachine.State.RUNNING: return
	timer.tick(delta)
	_apply_difficulty_ramp()
	if not parameters.tick(delta, _stage().active_parameters):
		failure_parameter_id = parameters.unsafe_parameter_id(_stage().active_parameters)
		_finish(RunStateMachine.State.FAILED)
		publish_snapshot()
		return
	_resolve_passed_items()
	if state_machine.state != RunStateMachine.State.RUNNING:
		publish_snapshot()
		return
	_spawn_items(delta)
	if timer.finished:
		score.add_completion_bonus(level.completion_bonus)
		_finish(RunStateMachine.State.COMPLETED)
	publish_snapshot()

func restart() -> void:
	# Restart abandons the current run.  It is not a result, so it must never
	# submit the current score as a best-score candidate.
	_reset_stage_run()
	start()

## Starts a fresh campaign from stage 1: total score, stage-entry baseline,
## and per-item familiarity all reset.
func restart_campaign() -> void:
	stage_entry_score = 0
	familiarity.clear()
	_apply_stage(0)
	_reset_stage_run()
	start()

func advance_stage() -> bool:
	if state_machine.state != RunStateMachine.State.COMPLETED or stage_index >= stages.size() - 1:
		return false
	stage_entry_score = score.score
	_apply_stage(stage_index + 1)
	_reset_stage_run()
	start()
	return true

## Difficulty ramp: spawn cadence and fall duration lerp from the stage's
## start values to its end values as the stage timer progresses. Equal start
## and end values mean no ramp.
func _apply_difficulty_ramp() -> void:
	var stage := _stage()
	var progress := clampf(timer.elapsed / stage.duration_seconds, 0.0, 1.0)
	level.spawn_interval = lerpf(stage.spawn_interval, stage.spawn_interval_end, progress)
	level.fall_duration = lerpf(stage.fall_duration, stage.fall_duration_end, progress)

## Emits a spirit_milestone event whenever momentum crosses 3/6/9 upward.
func _check_spirit_milestone() -> void:
	if score.momentum > _last_momentum and score.momentum in [3, 6, 9]:
		presentation_event.emit(&"spirit_milestone", {"tier": score.momentum / 3, "momentum": score.momentum})
	_last_momentum = score.momentum

func _spawn_items(delta: float) -> void:
	spawn_elapsed += delta
	if spawn_elapsed < level.spawn_interval:
		return
	if _lane_count(0) >= 2 and _lane_count(1) >= 2:
		spawn_elapsed = level.spawn_interval - 0.2
		return
	spawn_elapsed = 0.0
	if scheduler.bag.is_empty():
		_fill_bag()
	var item := scheduler.take_next(fairness)
	if item == null:
		# A malformed/remainder bag must not freeze spawning for the rest of the
		# run. Replace it with a fresh valid bag and try once more.
		_fill_bag()
		item = scheduler.take_next(fairness)
		if item == null:
			return
	if stage_index >= 1 and item.should_collect and not item.is_tradeoff and rng.next_float() < golden_chance:
		item = golden_item
	var lane := scheduler.next_lane(rng)
	if _lane_count(lane) >= 2:
		lane = 1 - lane
	var instance := ItemInstance.new(item, lane, timer.elapsed)
	active_items.append(instance)
	stage_spawn_count += 1
	familiarity[item.id] = familiarity.get(item.id, 0) + 1
	presentation_event.emit(&"spawn", {"instance_id": instance.get_instance_id(), "item_id": item.id, "lane": lane})

func _resolve_passed_items() -> void:
	for instance in active_items.duplicate():
		if instance.age(timer.elapsed) < level.fall_duration:
			continue
		if not instance.definition.should_collect:
			var awarded := score.reward_correct(instance.definition.pass_score)
			correct_decisions += 1
			hazards_passed += 1
			item_hazard_passes[instance.definition.id] = item_hazard_passes.get(instance.definition.id, 0) + 1
			presentation_event.emit(&"hazard_passed", {"instance_id": instance.get_instance_id(), "item_id": instance.definition.id, "lane": instance.lane_id, "score_delta": awarded})
		elif not instance.definition.is_tradeoff:
			missed_beneficial += 1
			score.break_momentum()
			presentation_event.emit(&"beneficial_missed", {"instance_id": instance.get_instance_id(), "item_id": instance.definition.id, "lane": instance.lane_id})
		active_items.erase(instance)
	if state_machine.state == RunStateMachine.State.RUNNING and _stage_objective_complete():
		_finish(RunStateMachine.State.COMPLETED)
	_check_spirit_milestone()

func _front_eligible_item(lane_id: int) -> ItemInstance:
	var chosen: ItemInstance = null
	for instance in active_items:
		var age := instance.age(timer.elapsed)
		if instance.lane_id != lane_id or age < level.fall_duration - level.cut_window or age >= level.fall_duration:
			continue
		if chosen == null or age > chosen.age(timer.elapsed):
			chosen = instance
	return chosen

func _lane_count(lane_id: int) -> int:
	var count := 0
	for instance in active_items:
		if instance.lane_id == lane_id:
			count += 1
	return count

func _fill_bag() -> void:
	var stage := _stage()
	scheduler.set_bag(SpawnBagGenerator.new().generate(_stage_simple_pool(stage), _items_for_ids(stage.trade_item_ids), rng, stage.simple_count, stage.trade_count, stage.active_parameters))

func _finish(next_state: RunStateMachine.State) -> void:
	if state_machine.transition(next_state):
		best_scores.submit(score.score)
		if next_state == RunStateMachine.State.FAILED:
			presentation_event.emit(&"failed", {"parameter": failure_parameter_id, "score": score.score})
		elif next_state == RunStateMachine.State.COMPLETED:
			presentation_event.emit(&"completed", {"score": score.score, "bonus": level.completion_bonus})

func _create_prototype_items() -> void:
	simple_items = [
		_item(&"fruit", {&"hunger": 7.0}, 100, true),
		_item(&"pillow", {&"rest": 7.0}, 100, true),
		_item(&"camera", {&"fun": 7.0}, 100, true),
		_item(&"friend_group", {&"social": 7.0}, 100, true),
		_item(&"soap", {&"hygiene": 7.0}, 100, true),
		_item(&"stale_snack", {&"hunger": -7.0}, 0, false, 50),
		_item(&"alarm_clock", {&"rest": -7.0}, 0, false, 50),
		_item(&"rain_cloud", {&"fun": -7.0}, 0, false, 50),
		_item(&"awkward_meeting", {&"social": -7.0}, 0, false, 50),
		_item(&"muddy_shoes", {&"hygiene": -7.0}, 0, false, 50)
	]
	trade_items = [
		_item(&"coffee", {&"hunger": -6.0, &"rest": 8.0, &"fun": 2.0}, 150, true, 0, true),
		_item(&"local_meal", {&"hunger": 8.0, &"rest": -4.0, &"fun": 2.0}, 150, true, 0, true),
		_item(&"night_market", {&"hunger": -3.0, &"rest": -5.0, &"fun": 9.0}, 150, true, 0, true),
		_item(&"street_festival", {&"rest": -4.0, &"fun": 8.0, &"social": 7.0}, 150, true, 0, true),
		_item(&"spa_day", {&"hunger": -3.0, &"rest": 8.0, &"fun": 2.0, &"hygiene": 8.0}, 150, true, 0, true),
		_item(&"group_tour", {&"rest": -5.0, &"fun": 6.0, &"social": 8.0}, 150, true, 0, true)
	]
	golden_item = _item(&"golden_coconut", {&"hunger": 4.0, &"rest": 4.0, &"fun": 4.0, &"social": 4.0, &"hygiene": 4.0}, 300, true)
	for item in simple_items + trade_items:
		item_catalog[item.id] = item
	item_catalog[golden_item.id] = golden_item

func _create_stages() -> void:
	var no_trade_items: Array[StringName] = []
	stages.clear()
	var base_items: Array[StringName] = [&"fruit", &"pillow", &"camera"]
	var hazards: Array[StringName] = [&"stale_snack", &"alarm_clock", &"rain_cloud"]
	var social_items: Array[StringName] = [&"friend_group", &"awkward_meeting"]
	var hygiene_items: Array[StringName] = [&"soap", &"muddy_shoes"]
	var trade_items_stage_three: Array[StringName] = [&"coffee", &"local_meal", &"night_market"]
	var trade_items_full: Array[StringName] = [&"coffee", &"local_meal", &"night_market", &"street_festival", &"spa_day", &"group_tour"]
	for level_number in range(1, 16):
		var chapter := int((level_number - 1) / 5)
		var active: Array[StringName] = [&"hunger", &"rest", &"fun"]
		var simple_pool: Array[StringName] = base_items.duplicate()
		if level_number >= 2:
			simple_pool.append_array(hazards)
		if chapter >= 1:
			active.append(&"social")
			simple_pool.append_array(social_items)
		if chapter >= 2:
			active.append(&"hygiene")
			simple_pool.append_array(hygiene_items)
		var level_trades: Array[StringName] = []
		if level_number >= 3:
			level_trades = trade_items_stage_three if chapter == 0 else trade_items_full
		var title := "LEVEL %02d - %s" % [level_number, _theme_name(chapter)]
		var lesson := _level_lesson(level_number, chapter)
		var collections: Dictionary[StringName, int] = {}
		var hazard_passes: Array[StringName] = []
		if level_number == 1:
			collections = {&"fruit": 2, &"pillow": 2, &"camera": 2}
		elif level_number == 2:
			collections = {&"fruit": 2, &"pillow": 2, &"camera": 2}
			hazard_passes = hazards
		var chapter_decay := -0.49 if chapter == 0 and level_number <= 2 else (-0.46 if chapter == 0 else (-0.43 if chapter == 1 else -0.41))
		stages.append(_stage_definition(level_number, &"level_%02d" % level_number, title, lesson, active, simple_pool, level_trades, 7 if level_number >= 3 else 3, 3 if level_number >= 3 else 0, 65.0 + minf(float(level_number - 1) * 1.5, 10.0), chapter_decay, 1.50 - minf(float(level_number - 1) * 0.035, 0.45), 3.45 - minf(float(level_number - 1) * 0.07, 1.0), {}, collections, hazard_passes, 1.30 - minf(float(level_number - 1) * 0.035, 0.45), 3.15 - minf(float(level_number - 1) * 0.07, 1.0), _theme_for_level(level_number)))

func _stage_definition(level_number: int, id: StringName, title: String, lesson: String, active_parameters: Array[StringName], simple_ids: Array[StringName], trade_ids: Array[StringName], simple_count: int, trade_count: int, duration: float, decay: float, spawn_interval: float, fall_duration: float, unlocks: Dictionary[StringName, int] = {}, collections: Dictionary[StringName, int] = {}, hazard_passes: Array[StringName] = [], spawn_interval_end: float = -1.0, fall_duration_end: float = -1.0, theme_id: StringName = &"tropical") -> StageDefinition:
	var stage := StageDefinition.new()
	stage.level_number = level_number; stage.id = id; stage.title = title; stage.lesson = lesson; stage.destination_id = theme_id; stage.theme_id = theme_id; stage.active_parameters = active_parameters; stage.simple_item_ids = simple_ids; stage.trade_item_ids = trade_ids; stage.simple_count = simple_count; stage.trade_count = trade_count; stage.duration_seconds = duration; stage.passive_decay_per_second = decay; stage.spawn_interval = spawn_interval; stage.fall_duration = fall_duration; stage.spawn_interval_end = spawn_interval if spawn_interval_end < 0.0 else spawn_interval_end; stage.fall_duration_end = fall_duration if fall_duration_end < 0.0 else fall_duration_end; stage.hazard_unlock_spawns = unlocks; stage.required_collections = collections; stage.required_hazard_passes = hazard_passes
	return stage

func _theme_for_level(level_number: int) -> StringName:
	return [&"tropical", &"sunset_city", &"countryside", &"ancient_ruins", &"crystal_isles"][(level_number - 1) % 5]

func _theme_name(chapter: int) -> String:
	return {"tropical": "SUNLIT COVE", "sunset_city": "NEON HARBOR", "countryside": "SERENE COUNTRY", "ancient_ruins": "ANCIENT RUINS", "crystal_isles": "CRYSTAL ISLES"}.get(_theme_for_level(chapter + 1), "ISLAND")

func _level_lesson(level_number: int, chapter: int) -> String:
	if level_number == 1:
		return "Learn the three essentials: collect each twice."
	if level_number == 2:
		return "Hazards are here now. Let every one pass."
	if level_number == 6:
		return "Social life joins the trip. Watch the fourth meter."
	if level_number == 11:
		return "Hygiene joins the journey. Balance all five needs."
	if chapter == 0:
		return "Keep the essentials centered and build your spirit."
	if chapter == 1:
		return "Prioritize the lowest need while the island speeds up."
	return "Read every item, then choose the best moment to cut."

func _apply_stage(next_index: int) -> void:
	stage_index = next_index
	level.duration_seconds = _stage().duration_seconds
	level.spawn_interval = _stage().spawn_interval
	level.fall_duration = _stage().fall_duration
	timer = TimerService.new(level.duration_seconds)
	for definition: ParameterDefinition in parameters.definitions:
		definition.decay_per_second = _stage().passive_decay_per_second * PARAMETER_DECAY_MULTIPLIERS.get(definition.id, 1.0)

func _reset_stage_run() -> void:
	state_machine = RunStateMachine.new()
	parameters.state.set_defaults(parameters.definitions)
	timer = TimerService.new(_stage().duration_seconds)
	score = ScoreService.new(); score.restore(stage_entry_score); resolver = ItemResolver.new(); scheduler = SpawnScheduler.new(); fairness = SpawnFairnessValidator.new(level.max_recovery_drought, _stage().active_parameters)
	active_items.clear(); failure_parameter_id = &""; spawn_elapsed = 0.0; lane_ready_at = {0: 0.0, 1: 0.0}; stage_spawn_count = 0; correct_decisions = 0; missed_beneficial = 0; harmful_cuts = 0; beneficial_collected = 0; hazards_passed = 0; hazards_cut = 0; tradeoffs_taken = 0; beneficial_tradeoffs = 0; failed_tradeoffs = 0; item_collections.clear(); item_hazard_passes.clear(); _last_momentum = 0; last_collected_item_id = &""; last_collected_at = -1000.0

func _stage_objective_complete() -> bool:
	var stage := _stage()
	if stage.required_collections.is_empty() and stage.required_hazard_passes.is_empty():
		return false
	for item_id in stage.required_collections:
		if item_collections.get(item_id, 0) < stage.required_collections[item_id]:
			return false
	for item_id in stage.required_hazard_passes:
		if item_hazard_passes.get(item_id, 0) < 1:
			return false
	return true

func _stage() -> StageDefinition:
	return stages[stage_index]

func _stage_simple_pool(stage: StageDefinition) -> Array[ItemDefinition]:
	var result: Array[ItemDefinition] = []
	for id in stage.simple_item_ids:
		var unlock_at: int = stage.hazard_unlock_spawns.get(id, 0)
		if stage_spawn_count >= unlock_at:
			result.append(item_catalog[id])
	return result

func _items_for_ids(ids: Array[StringName]) -> Array[ItemDefinition]:
	var result: Array[ItemDefinition] = []
	for id in ids: result.append(item_catalog[id])
	return result

func _item(id: StringName, deltas: Dictionary[StringName, float], item_score: int, collect: bool, pass_points: int = 0, tradeoff: bool = false) -> ItemDefinition:
	var item := ItemDefinition.new()
	item.id = id
	item.deltas = deltas
	item.score = item_score
	item.should_collect = collect
	item.pass_score = pass_points
	item.is_tradeoff = tradeoff
	return item

func publish_snapshot() -> void:
	var item_snapshots: Array[Dictionary] = []
	for instance in active_items:
		var seen: int = familiarity.get(instance.definition.id, 0)
		var in_cut_window := instance.age(timer.elapsed) >= level.fall_duration - level.cut_window and instance.age(timer.elapsed) < level.fall_duration
		var front_item := _front_eligible_item(instance.lane_id)
		var cut_ready := in_cut_window and front_item != null and front_item.get_instance_id() == instance.get_instance_id()
		if cut_ready and not instance.cut_window_announced:
			instance.cut_window_announced = true
			presentation_event.emit(&"cut_window_open", {"instance_id": instance.get_instance_id(), "item_id": instance.definition.id, "lane": instance.lane_id, "collect": instance.definition.should_collect, "decision": _decision_label(instance.definition)})
		item_snapshots.append({"instance_id": instance.get_instance_id(), "id": instance.definition.id, "lane": instance.lane_id, "progress": clampf(instance.age(timer.elapsed) / level.fall_duration, 0.0, 1.0), "cut_ready": cut_ready, "collect": instance.definition.should_collect, "tradeoff": instance.definition.is_tradeoff, "knowledge": "NEW" if seen <= 1 else ("LEARNING" if seen <= 5 else "KNOWN"), "familiarity_count": seen, "show_effects": instance.definition.is_tradeoff or seen <= 5 or not _active_sequence_rule(instance.definition).is_empty(), "deltas": _preview_deltas(instance.definition), "decision": _decision_label(instance.definition), "decision_reason": _decision_reason(instance.definition)})
	var weakest := _weakest_parameter()
	var snapshot: Dictionary = {"state": state_machine.state, "score": score.score, "best_score": best_scores.best_score, "bonus": level.completion_bonus, "remaining": timer.remaining(), "parameters": parameters.state.values.duplicate(), "active_parameters": _stage().active_parameters.duplicate(), "failure_parameter": failure_parameter_id, "stage": stage_index + 1, "stage_title": _stage().title, "stage_lesson": _stage().lesson, "theme_id": _stage().theme_id, "objective": _objective_text(), "priority_parameter": weakest["id"], "priority_value": weakest["value"], "momentum": score.momentum, "correct_decisions": correct_decisions, "missed_beneficial": missed_beneficial, "harmful_cuts": harmful_cuts, "beneficial_collected": beneficial_collected, "hazards_passed": hazards_passed, "hazards_cut": hazards_cut, "tradeoffs_taken": tradeoffs_taken, "beneficial_tradeoffs": beneficial_tradeoffs, "failed_tradeoffs": failed_tradeoffs, "items": item_snapshots}
	snapshot_published.emit(snapshot)

func _weakest_parameter() -> Dictionary:
	var selected_id: StringName = &"hunger"
	var selected_value: float = parameters.state.values.get(selected_id, 50.0)
	for id: StringName in _stage().active_parameters:
		var value: float = parameters.state.values.get(id, 50.0)
		if value < selected_value:
			selected_id = id
			selected_value = value
	return {"id": selected_id, "value": selected_value}

func _decision_label(item: ItemDefinition) -> String:
	if not item.should_collect:
		return "LET PASS"
	if not _active_sequence_rule(item).is_empty():
		return "WAIT"
	var values: Dictionary = parameters.state.values
	var safe := true
	var before_distance := 0.0
	var after_distance := 0.0
	for id: StringName in _stage().active_parameters:
		var current: float = values.get(id, 50.0)
		var next: float = current + item.deltas.get(id, 0.0)
		safe = safe and next >= 20.0 and next <= 80.0
		before_distance += absf(current - 50.0)
		after_distance += absf(next - 50.0)
	if not safe:
		return "TOO RISKY"
	if item.is_tradeoff:
		return "GOOD CHOICE" if after_distance < before_distance else "SAVE IT"
	return "COLLECT"

func _decision_reason(item: ItemDefinition) -> String:
	if not item.should_collect:
		return "avoid the hit"
	var sequence_rule := _active_sequence_rule(item)
	if not sequence_rule.is_empty():
		return "%s after %s" % [String(sequence_rule.get("label", "bad combo")).to_lower(), String(last_collected_item_id).replace("_", " ")]
	if item.is_tradeoff:
		return "moves you toward center" if _decision_label(item) == "GOOD CHOICE" else "wait for a better state"
	return "supports %s" % _parameter_label(_positive_parameter(item))

func _positive_parameter(item: ItemDefinition) -> StringName:
	var best_id: StringName = &"hunger"
	var best_delta := -INF
	for id: StringName in item.deltas:
		if item.deltas[id] > best_delta:
			best_id = id
			best_delta = item.deltas[id]
	return best_id

func _active_sequence_rule(item: ItemDefinition) -> Dictionary:
	if last_collected_item_id == &"" or timer.elapsed - last_collected_at < 0.0:
		return {}
	for rule: Dictionary in SEQUENCE_RULES:
		if _stage().level_number < int(rule["min_level"]):
			continue
		if item.id == rule["current"] and last_collected_item_id == rule["previous"] and timer.elapsed - last_collected_at <= float(rule["window"]):
			return rule
	return {}

func _preview_deltas(item: ItemDefinition) -> Dictionary[StringName, float]:
	var result: Dictionary[StringName, float] = item.deltas.duplicate()
	var rule := _active_sequence_rule(item)
	for parameter_id: StringName in rule.get("deltas", {}):
		result[parameter_id] = result.get(parameter_id, 0.0) + rule["deltas"][parameter_id]
	return result

func _parameter_label(id: StringName) -> String:
	return {"hunger": "hunger", "rest": "rest", "fun": "fun", "social": "social", "hygiene": "hygiene"}.get(id, "your needs")

func _objective_text() -> String:
	if stage_index == 0:
		return "ESSENTIALS  F %d/2  P %d/2  C %d/2" % [item_collections.get(&"fruit", 0), item_collections.get(&"pillow", 0), item_collections.get(&"camera", 0)]
	if stage_index == 1:
		return "ESSENTIALS + PASS EACH HAZARD"
	if stage_index == 5:
		return "NEW NEED: SOCIAL  KEEP THE GROUP CLOSE"
	if stage_index == 10:
		return "NEW NEED: HYGIENE  KEEP EVERY NEED SAFE"
	return "LEVEL %02d  KEEP ALL NEEDS SAFE" % _stage().level_number
