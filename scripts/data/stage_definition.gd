class_name StageDefinition
extends Resource

@export var id: StringName
@export var title: String
@export var lesson: String
@export var destination_id: StringName = &"tropical"
@export var theme_id: StringName = &"tropical"
@export var active_parameters: Array[StringName] = [&"hunger", &"rest", &"fun"]
@export var duration_seconds: float = 120.0
@export var passive_decay_per_second: float = -0.3
@export var simple_item_ids: Array[StringName] = []
@export var trade_item_ids: Array[StringName] = []
@export var simple_count: int = 7
@export var trade_count: int = 3
@export var spawn_interval: float = 1.4
@export var fall_duration: float = 3.2
## End-of-stage values for the difficulty ramp; equal to the start values
## means no ramp. The coordinator lerps between start and end over the stage.
@export var spawn_interval_end: float = 1.4
@export var fall_duration_end: float = 3.2
@export var hazard_unlock_spawns: Dictionary[StringName, int] = {}
@export var required_collections: Dictionary[StringName, int] = {}
@export var required_hazard_passes: Array[StringName] = []
