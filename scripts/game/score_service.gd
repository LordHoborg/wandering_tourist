class_name ScoreService
extends RefCounted

var score: int = 0

func add_simple(points: int) -> void:
	score += points

func add_tradeoff(before_distance: float, after_distance: float, failed: bool, reward: int = 150) -> void:
	if not failed and after_distance < before_distance:
		score += reward

func add_completion_bonus(bonus: int) -> void:
	score += bonus
