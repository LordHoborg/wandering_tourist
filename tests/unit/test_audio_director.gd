extends SceneTree

const AudioDirectorClass = preload("res://scripts/ui/audio_director.gd")
const SettingsClass = preload("res://autoload/app_settings.gd")
var passed := 0
var failed := 0

func _initialize() -> void:
	print("TEST START")
	# Headless script runs do not register the autoload; provide one by name.
	var settings = root.get_node_or_null("AppSettings")
	if settings == null:
		settings = SettingsClass.new()
		settings.name = "AppSettings"
		root.add_child(settings)
	var director = AudioDirectorClass.new()
	director.settings = settings
	root.add_child(director)
	var emitted_kinds: Array[StringName] = [&"stage_started", &"spawn", &"cut_success", &"harmful_cut", &"risky_combo", &"hazard_passed", &"beneficial_missed", &"failed", &"completed", &"warning", &"ui_start", &"cut_window_open", &"coin_collected", &"bonus_collected", &"coin_bonus_claimed"]
	var all_covered := true
	for kind in emitted_kinds:
		if not director.has_cue(kind):
			all_covered = false
	_check(all_covered, "every presentation event kind has a cue")
	var streams_valid := true
	for kind in emitted_kinds:
		var stream: AudioStreamWAV = director.streams[kind]
		if stream.mix_rate != AudioDirectorClass.MIX_RATE or stream.format != AudioStreamWAV.FORMAT_16_BITS or stream.data.size() == 0:
			streams_valid = false
	_check(streams_valid, "generated cue streams are valid non-empty WAVs")
	var synthesized := AudioDirectorClass.synthesize([[440.0, 0.1]])
	var synthesized_again := AudioDirectorClass.synthesize([[440.0, 0.1]])
	_check(synthesized.data == synthesized_again.data, "synthesis is deterministic")
	var silent := AudioDirectorClass.synthesize([[0.0, 0.1]])
	var silent_centered := true
	for byte in silent.data:
		if byte != 0:
			silent_centered = false
	_check(silent_centered, "zero frequency produces silence")
	var loud := false
	for byte in synthesized.data:
		if byte != 0:
			loud = true
	_check(loud, "tone produces audible samples")
	var ambience_stream: AudioStreamWAV = AudioDirectorClass.synthesize_ambience()
	_check(ambience_stream.loop_mode == AudioStreamWAV.LOOP_FORWARD and ambience_stream.loop_end * 2 == ambience_stream.data.size(), "ambience stream loops")
	_check(ambience_stream.data.size() == AudioDirectorClass.MIX_RATE * int(AudioDirectorClass.AMBIENCE_SECONDS) * 2, "ambience length matches loop seconds")
	_check(ambience_stream.data == AudioDirectorClass.synthesize_ambience().data, "ambience synthesis is deterministic")
	var menu_stream: AudioStreamWAV = AudioDirectorClass.synthesize_menu_music()
	_check(menu_stream.loop_mode == AudioStreamWAV.LOOP_FORWARD and menu_stream.data.size() > 0, "menu music is a looping stream")
	_check(menu_stream.data == AudioDirectorClass.synthesize_menu_music().data, "menu music synthesis is deterministic")
	_check(
		AudioDirectorClass.MENU_AUDIO_ASSET.get_length() > 10.0
		and AudioDirectorClass.GAME_AUDIO_ASSET.get_length() > 10.0
		and AudioDirectorClass.MENU_AUDIO_ASSET.format == AudioStreamWAV.FORMAT_16_BITS
		and AudioDirectorClass.GAME_AUDIO_ASSET.format == AudioStreamWAV.FORMAT_16_BITS,
		"imported background audio assets are valid PCM WAVs"
	)
	_check(director.ambience != null and director.ambience.stream == director.menu_stream and director.menu_stream.loop_mode == AudioStreamWAV.LOOP_FORWARD, "menu music starts as the active looping stream")
	director.set_menu_mode(false)
	_check(director.ambience.stream == director.game_stream and director.game_stream.loop_mode == AudioStreamWAV.LOOP_FORWARD, "game ambience replaces menu music safely")
	director.set_menu_mode(true)
	_check(director.ambience.stream == director.menu_stream, "menu music can resume after gameplay")
	var saved_muted: bool = settings.muted
	var saved_volume: float = settings.sfx_volume
	settings.muted = true
	_check(not director.play_cue(&"cut_success"), "muted blocks playback")
	settings.muted = false
	settings.sfx_volume = 0.0
	_check(not director.play_cue(&"cut_success"), "zero volume blocks playback")
	settings.sfx_volume = 1.0
	_check(director.play_cue(&"cut_success"), "cue plays when audio enabled")
	_check(not director.play_cue(&"does_not_exist"), "unknown cue is an inert no-op")
	settings.sfx_volume = 0.5
	director.play_cue(&"warning")
	var last_index: int = (director._next_player + AudioDirectorClass.POOL_SIZE - 1) % AudioDirectorClass.POOL_SIZE
	_check(absf(director._players[last_index].volume_db - linear_to_db(0.5)) < 0.01, "volume maps to player decibels")
	settings.muted = saved_muted
	settings.sfx_volume = saved_volume
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
