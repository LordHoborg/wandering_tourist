class_name DeterministicRng
extends RefCounted

var generator := RandomNumberGenerator.new()
func _init(seed_value: int) -> void:
	generator.seed = seed_value
func next_index(size: int) -> int:
	return generator.randi_range(0, size - 1)
func next_float() -> float:
	return generator.randf()
