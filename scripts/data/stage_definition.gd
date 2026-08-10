class_name StageDefinition
extends Resource

@export var id: StringName
@export var title: String
@export var lesson: String
@export var destination_id: StringName = &"tropical"
@export var active_parameters: Array[StringName] = [&"hunger", &"rest", &"fun"]
@export var simple_item_ids: Array[StringName] = []
@export var trade_item_ids: Array[StringName] = []
@export var simple_count: int = 7
@export var trade_count: int = 3
@export var spawn_interval: float = 1.4
@export var fall_duration: float = 3.2
@export var hazard_unlock_spawns: Dictionary[StringName, int] = {}
