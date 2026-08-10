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

signal snapshot_published(snapshot: Dictionary)
var state_machine: RunStateMachine = RunStateMachine.new()
var parameters: ParameterService
var timer: TimerService
var score: ScoreService = ScoreService.new()
var best_scores: BestScoreRepository

func _init(definitions: Array[ParameterDefinition], duration: float, repository_path: String) -> void:
	parameters = ParameterService.new(definitions)
	timer = TimerService.new(duration)
	best_scores = BestScoreRepository.new(repository_path)

func start() -> bool:
	return state_machine.transition(RunStateMachine.State.RUNNING)

func pause_intent() -> bool:
	if state_machine.state != RunStateMachine.State.RUNNING: return false
	timer.paused = true
	return state_machine.transition(RunStateMachine.State.PAUSED)

func resume() -> bool:
	if state_machine.state != RunStateMachine.State.PAUSED: return false
	timer.paused = false
	return state_machine.transition(RunStateMachine.State.RUNNING)

func tick(delta: float) -> void:
	if state_machine.state != RunStateMachine.State.RUNNING: return
	timer.tick(delta)
	if not parameters.tick(delta): state_machine.transition(RunStateMachine.State.FAILED)
	elif timer.finished: state_machine.transition(RunStateMachine.State.COMPLETED); score.add_completion_bonus(500); best_scores.submit(score.score)
	publish_snapshot()

func publish_snapshot() -> void:
	var snapshot: Dictionary = {"state": state_machine.state, "score": score.score, "remaining": timer.remaining(), "parameters": parameters.state.values.duplicate()}
	snapshot_published.emit(snapshot)
