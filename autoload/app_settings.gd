extends Node

const DEFAULT_PATH := "user://app_settings.cfg"

var reduced_motion: bool = false
var sfx_volume: float = 1.0
var muted: bool = false
var settings_path: String = DEFAULT_PATH

func _ready() -> void:
	load_settings()

func set_muted(value: bool) -> void:
	muted = value
	save_settings()

func set_sfx_volume(value: float) -> void:
	sfx_volume = clampf(value, 0.0, 1.0)
	save_settings()

func set_reduced_motion(value: bool) -> void:
	reduced_motion = value
	save_settings()

func load_settings() -> void:
	var config := ConfigFile.new()
	if config.load(settings_path) != OK:
		return
	muted = bool(config.get_value("audio", "muted", muted))
	sfx_volume = clampf(float(config.get_value("audio", "sfx_volume", sfx_volume)), 0.0, 1.0)
	reduced_motion = bool(config.get_value("accessibility", "reduced_motion", reduced_motion))

func save_settings() -> void:
	var config := ConfigFile.new()
	config.set_value("audio", "muted", muted)
	config.set_value("audio", "sfx_volume", sfx_volume)
	config.set_value("accessibility", "reduced_motion", reduced_motion)
	config.save(settings_path)
