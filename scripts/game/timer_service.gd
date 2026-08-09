class_name TimerService
extends RefCounted

signal completed
var duration: float
var elapsed: float = 0.0
var paused: bool = false
var finished: bool = false

func _init(duration_seconds: float) -> void:
	duration = duration_seconds

func tick(delta: float) -> void:
	if paused or finished:
		return
	elapsed = minf(duration, elapsed + delta)
	if is_equal_approx(elapsed, duration):
		finished = true
		completed.emit()

func remaining() -> float:
	return duration - elapsed
