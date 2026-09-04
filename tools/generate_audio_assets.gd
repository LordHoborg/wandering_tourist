extends SceneTree

const AudioDirectorClass = preload("res://scripts/ui/audio_director.gd")

func _initialize() -> void:
	_write_wav("res://resources/audio/menu_music.wav", AudioDirectorClass.synthesize_menu_music())
	_write_wav("res://resources/audio/game_ambience.wav", AudioDirectorClass.synthesize_ambience())
	print("AUDIO ASSETS GENERATED")
	quit()

func _write_wav(path: String, stream: AudioStreamWAV) -> void:
	var pcm: PackedByteArray = stream.data
	var file := FileAccess.open(path, FileAccess.WRITE)
	file.store_buffer(_header(pcm.size(), stream.mix_rate))
	file.store_buffer(pcm)
	file.close()

func _header(data_size: int, sample_rate: int) -> PackedByteArray:
	var header := PackedByteArray()
	header.append_array("RIFF".to_ascii_buffer())
	_append_u32(header, 36 + data_size)
	header.append_array("WAVE".to_ascii_buffer())
	header.append_array("fmt ".to_ascii_buffer())
	_append_u32(header, 16)
	_append_u16(header, 1)
	_append_u16(header, 1)
	_append_u32(header, sample_rate)
	_append_u32(header, sample_rate * 2)
	_append_u16(header, 2)
	_append_u16(header, 16)
	header.append_array("data".to_ascii_buffer())
	_append_u32(header, data_size)
	return header

func _append_u16(data: PackedByteArray, value: int) -> void:
	data.append(value & 0xff)
	data.append((value >> 8) & 0xff)

func _append_u32(data: PackedByteArray, value: int) -> void:
	data.append(value & 0xff)
	data.append((value >> 8) & 0xff)
	data.append((value >> 16) & 0xff)
	data.append((value >> 24) & 0xff)
