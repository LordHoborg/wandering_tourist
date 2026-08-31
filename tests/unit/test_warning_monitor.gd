extends SceneTree

const WarningMonitorClass = preload("res://scripts/ui/warning_monitor.gd")
var passed := 0
var failed := 0

func _init() -> void:
	print("TEST START")
	var monitor = WarningMonitorClass.new()
	var safe := {&"hunger": 50.0, &"rest": 50.0, &"fun": 50.0}
	_check(monitor.update(safe, 0.0).is_empty(), "safe values produce no cue")
	var low := {&"hunger": 28.0, &"rest": 50.0, &"fun": 50.0}
	_check(monitor.update(low, 1.0) == [&"warning"], "cue on warning band entry")
	_check(monitor.update(low, 2.0).is_empty(), "no repeat before reminder period")
	_check(monitor.update(low, 4.9).is_empty(), "still quiet inside reminder window")
	_check(monitor.update(low, 6.1) == [&"warning"], "one reminder after five seconds in band")
	_check(monitor.update(low, 11.2) == [&"warning"], "next reminder five seconds later")
	_check(monitor.update(safe, 12.0).is_empty(), "leaving the band is silent")
	_check(monitor.update(low, 13.0) == [&"warning"], "re-entry cues again after exit reset")
	monitor.reset()
	_check(monitor.update(low, 100.0) == [&"warning"], "reset clears reminder schedule")
	var high := {&"hunger": 50.0, &"rest": 75.0, &"fun": 50.0}
	monitor.reset()
	_check(monitor.update(high, 0.0) == [&"warning"], "upper band entry also cues")
	var two := {&"hunger": 10.0, &"rest": 50.0, &"fun": 90.0}
	monitor.reset()
	_check(monitor.update(two, 0.0).size() == 2, "simultaneous bands each cue once")
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
