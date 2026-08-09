class_name BestScoreRepository
extends RefCounted

var path: String
var best_score: int = 0

func _init(storage_path: String) -> void:
	path = storage_path
	load_best()

func submit(score: int) -> bool:
	if score <= best_score:
		return false
	best_score = score
	var file := FileAccess.open(path, FileAccess.WRITE)
	file.store_32(best_score)
	return true

func load_best() -> void:
	if FileAccess.file_exists(path):
		var file := FileAccess.open(path, FileAccess.READ)
		best_score = file.get_32()
