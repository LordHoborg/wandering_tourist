extends SceneTree

## Dev tool: boots the real scene, captures the title screen and a few seconds
## of live gameplay to PNG, then quits. Run windowed (not headless):
##   tools\godot\Godot_v4.7.1-stable_win64_console.exe --path . --script tools/capture_screenshots.gd

var _frames := 0
var _gameplay_root: Node = null

func _initialize() -> void:
	root.add_child(load("res://scenes/app/app_root.tscn").instantiate())
	_gameplay_root = root.get_node_or_null("AppRoot/GameplayRoot")

func _process(_delta: float) -> bool:
	_frames += 1
	if _frames == 30:
		_save("user://shot_title.png")
	if _frames == 60 and _gameplay_root != null:
		_gameplay_root._start_run()
	if _frames == 420:
		_save("user://shot_gameplay.png")
	if _frames >= 430:
		print("SCREENSHOTS DONE")
		quit(0)
	return false

func _save(path: String) -> void:
	var image := root.get_texture().get_image()
	image.save_png(ProjectSettings.globalize_path(path))
	print("SAVED ", path)
