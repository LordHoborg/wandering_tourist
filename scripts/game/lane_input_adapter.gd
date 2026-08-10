class_name LaneInputAdapter
extends RefCounted

signal lane_activated(lane_id: int)

func activate_from_pointer(lane_id: int) -> void:
	if lane_id == 0 or lane_id == 1:
		lane_activated.emit(lane_id)
