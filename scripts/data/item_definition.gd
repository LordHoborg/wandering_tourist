class_name ItemDefinition
extends Resource

@export var id: StringName
@export var deltas: Dictionary[StringName, float] = {}
@export var score: int = 0
@export var is_tradeoff: bool = false
@export var should_collect: bool = true
@export var pass_score: int = 0
