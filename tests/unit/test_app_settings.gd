extends SceneTree

const SettingsClass = preload("res://autoload/app_settings.gd")
var passed := 0
var failed := 0

func _init() -> void:
	print("TEST START")
	var path := "user://app_settings_test.cfg"
	DirAccess.remove_absolute(ProjectSettings.globalize_path(path))
	var settings = SettingsClass.new()
	settings.settings_path = path
	_check(not settings.muted and settings.sfx_volume == 1.0 and not settings.reduced_motion, "settings defaults")
	settings.set_sfx_volume(1.7)
	_check(settings.sfx_volume == 1.0, "volume clamped above")
	settings.set_sfx_volume(-0.5)
	_check(settings.sfx_volume == 0.0, "volume clamped below")
	settings.set_muted(true)
	settings.set_reduced_motion(true)
	settings.set_sfx_volume(0.5)
	var reloaded = SettingsClass.new()
	reloaded.settings_path = path
	reloaded.load_settings()
	_check(reloaded.muted and reloaded.reduced_motion and reloaded.sfx_volume == 0.5, "settings persistence round-trip")
	var fresh = SettingsClass.new()
	fresh.settings_path = "user://app_settings_missing.cfg"
	DirAccess.remove_absolute(ProjectSettings.globalize_path(fresh.settings_path))
	fresh.load_settings()
	_check(not fresh.muted and fresh.sfx_volume == 1.0, "missing file keeps defaults")
	DirAccess.remove_absolute(ProjectSettings.globalize_path(path))
	print("TESTS PASSED: %d" % passed)
	print("TESTS FAILED: %d" % failed)
	quit(0 if failed == 0 else 1)

func _check(condition: bool, name: String) -> void:
	if condition:
		passed += 1
		print("PASS: %s" % name)
	else:
		failed += 1
		push_error("FAIL: %s" % name)
