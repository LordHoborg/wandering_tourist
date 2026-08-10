extends Node

var coordinator: GameplayCoordinator

func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_FOCUS_OUT:
		if coordinator != null:
			coordinator.pause_intent()
