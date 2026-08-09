extends SceneTree

const TimerServiceClass = preload("res://scripts/game/timer_service.gd")
const ScoreServiceClass = preload("res://scripts/game/score_service.gd")
const BestScoreRepositoryClass = preload("res://scripts/game/best_score_repository.gd")
var passed := 0
var failed := 0

func _init() -> void:
	print("TEST START")
	var timer = TimerServiceClass.new(120.0)
	_check(timer.elapsed == 0.0 and timer.remaining() == 120.0, "timer initialization")
	timer.tick(1.0)
	_check(timer.elapsed == 1.0, "active time progression")
	timer.tick(119.0)
	_check(timer.finished and timer.elapsed == 120.0, "exact 120-second completion")
	timer.tick(1.0)
	_check(timer.elapsed == 120.0, "no progression after completion")
	var paused_timer = TimerServiceClass.new(120.0)
	paused_timer.paused = true
	paused_timer.tick(5.0)
	_check(paused_timer.elapsed == 0.0, "pause freeze")
	paused_timer.paused = false
	paused_timer.tick(1.0)
	_check(paused_timer.elapsed == 1.0, "resume continuation")
	var score = ScoreServiceClass.new()
	score.add_simple(100)
	_check(score.score == 100, "simple event scoring")
	score.add_tradeoff(30.0, 20.0, false)
	_check(score.score == 250, "trade-off contextual scoring")
	score.add_tradeoff(20.0, 30.0, false)
	_check(score.score == 250, "zero harmful trade-off scoring")
	score.add_completion_bonus(500)
	_check(score.score == 750, "completion bonus")
	var repo_path := "user://best_score_test.dat"
	DirAccess.remove_absolute(ProjectSettings.globalize_path(repo_path))
	var repo = BestScoreRepositoryClass.new(repo_path)
	_check(repo.best_score == 0, "best score default")
	_check(repo.submit(100), "first score persistence")
	_check(not repo.submit(100) and not repo.submit(50), "lower/equal score rejection")
	_check(repo.submit(200) and BestScoreRepositoryClass.new(repo_path).best_score == 200, "best score reload persistence")
	print("TESTS PASSED: %d" % passed)
	print("TESTS FAILED: %d" % failed)
	quit(0 if failed == 0 else 1)

func _check(condition: bool, name: String) -> void:
	if condition:
		passed += 1
		print("PASS: %s" % name)
	else:
		failed += 1
		push_error("FAIL: %s" % name)
