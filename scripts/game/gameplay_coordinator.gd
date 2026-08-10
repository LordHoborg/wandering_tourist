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

signal snapshot_published(snapshot: Dictionary)
signal presentation_event(kind: StringName, data: Dictionary)
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
var active_items: Array[ItemInstance] = []
var spawn_elapsed: float = 0.0
var lane_ready_at: Dictionary[int, float] = {0: 0.0, 1: 0.0}
var level := LevelDefinition.new()
var failure_parameter_id: StringName = &""

func _init(definitions: Array[ParameterDefinition], duration: float, repository_path: String) -> void:
	parameters = ParameterService.new(definitions)
	timer = TimerService.new(duration)
	best_scores = BestScoreRepository.new(repository_path)
	level.duration_seconds = duration
	fairness = SpawnFairnessValidator.new(level.max_recovery_drought)
	_create_prototype_items()

func start() -> bool:
	if not state_machine.transition(RunStateMachine.State.RUNNING):
		return false
	_fill_bag()
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
	var transaction = resolver.resolve(item, parameters, true)
	if item.is_tradeoff:
		score.add_tradeoff(transaction.before_distance, transaction.after_distance, not transaction.safe)
	elif item.should_collect:
		score.add_simple(item.score)
	active_items.erase(instance)
	var score_delta := score.score - score_before
	var event_data := {"instance_id": instance.get_instance_id(), "item_id": item.id, "lane": lane_id, "score_delta": score_delta, "deltas": transaction.deltas, "safe": transaction.safe}
	if not item.should_collect:
		presentation_event.emit(&"harmful_cut", event_data)
	elif transaction.safe:
		presentation_event.emit(&"cut_success", event_data)
	else:
		presentation_event.emit(&"harmful_cut", event_data)
	if not transaction.safe:
		failure_parameter_id = parameters.unsafe_parameter_id()
		_finish(RunStateMachine.State.FAILED)
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
	if not parameters.tick(delta):
		failure_parameter_id = parameters.unsafe_parameter_id()
		_finish(RunStateMachine.State.FAILED)
		publish_snapshot()
		return
	_resolve_passed_items()
	_spawn_items(delta)
	if timer.finished:
		score.add_completion_bonus(level.completion_bonus)
		_finish(RunStateMachine.State.COMPLETED)
	publish_snapshot()

func restart() -> void:
	# Restart abandons the current run.  It is not a result, so it must never
	# submit the current score as a best-score candidate.
	state_machine = RunStateMachine.new()
	parameters.state.set_defaults(parameters.definitions)
	timer = TimerService.new(level.duration_seconds)
	score = ScoreService.new()
	resolver = ItemResolver.new()
	scheduler = SpawnScheduler.new()
	fairness = SpawnFairnessValidator.new(level.max_recovery_drought)
	active_items.clear()
	failure_parameter_id = &""
	spawn_elapsed = 0.0
	lane_ready_at = {0: 0.0, 1: 0.0}
	start()

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
	var lane := scheduler.next_lane(rng)
	if _lane_count(lane) >= 2:
		lane = 1 - lane
	var instance := ItemInstance.new(item, lane, timer.elapsed)
	active_items.append(instance)
	presentation_event.emit(&"spawn", {"instance_id": instance.get_instance_id(), "item_id": item.id, "lane": lane})

func _resolve_passed_items() -> void:
	for instance in active_items.duplicate():
		if instance.age(timer.elapsed) < level.fall_duration:
			continue
		if not instance.definition.should_collect:
			score.add_simple(instance.definition.pass_score)
			presentation_event.emit(&"hazard_passed", {"instance_id": instance.get_instance_id(), "item_id": instance.definition.id, "lane": instance.lane_id, "score_delta": instance.definition.pass_score})
		active_items.erase(instance)

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
	scheduler.set_bag(SpawnBagGenerator.new().generate(simple_items, trade_items, rng))

func _finish(next_state: RunStateMachine.State) -> void:
	if state_machine.transition(next_state):
		best_scores.submit(score.score)
		if next_state == RunStateMachine.State.FAILED:
			presentation_event.emit(&"failed", {"parameter": failure_parameter_id, "score": score.score})
		elif next_state == RunStateMachine.State.COMPLETED:
			presentation_event.emit(&"completed", {"score": score.score, "bonus": level.completion_bonus})

func _create_prototype_items() -> void:
	simple_items = [_item(&"fruit", {&"hunger": 7.0}, 100, true), _item(&"pillow", {&"rest": 7.0}, 100, true), _item(&"camera", {&"fun": 7.0}, 100, true), _item(&"stale_snack", {&"hunger": -7.0}, 0, false, 50), _item(&"alarm_clock", {&"rest": -7.0}, 0, false, 50), _item(&"rain_cloud", {&"fun": -7.0}, 0, false, 50)]
	trade_items = [_item(&"coffee", {&"hunger": -6.0, &"rest": 8.0, &"fun": 2.0}, 150, true, 0, true), _item(&"local_meal", {&"hunger": 8.0, &"rest": -4.0, &"fun": 2.0}, 150, true, 0, true), _item(&"night_market", {&"hunger": -3.0, &"rest": -5.0, &"fun": 9.0}, 150, true, 0, true)]

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
		item_snapshots.append({"instance_id": instance.get_instance_id(), "id": instance.definition.id, "lane": instance.lane_id, "progress": clampf(instance.age(timer.elapsed) / level.fall_duration, 0.0, 1.0), "cut_ready": instance.age(timer.elapsed) >= level.fall_duration - level.cut_window, "collect": instance.definition.should_collect, "tradeoff": instance.definition.is_tradeoff})
	var snapshot: Dictionary = {"state": state_machine.state, "score": score.score, "best_score": best_scores.best_score, "remaining": timer.remaining(), "parameters": parameters.state.values.duplicate(), "failure_parameter": failure_parameter_id, "items": item_snapshots}
	snapshot_published.emit(snapshot)
