class_name ScoreService
extends RefCounted

var score: int = 0
var momentum: int = 0
const MAX_MOMENTUM := 9
const MOMENTUM_STEP := 3
const MOMENTUM_BONUS := 10

func add_simple(points: int) -> void:
	score += points

func add_tradeoff(before_distance: float, after_distance: float, failed: bool, reward: int = 150) -> int:
	if not failed and after_distance < before_distance:
		return reward_correct(reward)
	break_momentum()
	return 0

func add_completion_bonus(bonus: int) -> void:
	score += bonus

func reward_correct(points: int) -> int:
	momentum = mini(MAX_MOMENTUM, momentum + 1)
	var awarded: int = points + int(momentum / MOMENTUM_STEP) * MOMENTUM_BONUS
	score += awarded
	return awarded

func break_momentum() -> void:
	momentum = maxi(0, momentum - 2)

## Restores a previously accumulated campaign score (e.g. rolling back to the
## stage-entry total on retry) and clears momentum.
func restore(points: int) -> void:
	score = points
	momentum = 0
