extends Node

func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_FOCUS_OUT:
		# Phase 3 UI/coordinator will translate this to a pause intent.
		pass
