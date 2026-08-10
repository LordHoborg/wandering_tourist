class_name TravelFeedbackLayer
extends Control

func show_feedback(text: String, color: Color, at: Vector2) -> void:
	var label := Label.new(); label.text = text; label.position = at; label.add_theme_font_size_override("font_size", 25); label.add_theme_color_override("font_color", color); label.add_theme_color_override("font_shadow_color", Color(0.02, 0.05, 0.12, 0.9)); label.add_theme_constant_override("shadow_offset_x", 2); label.add_theme_constant_override("shadow_offset_y", 3); label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(label)
	var tween := create_tween()
	if not AppSettings.reduced_motion: tween.parallel().tween_property(label, "position:y", at.y - 72.0, 0.65); tween.parallel().tween_property(label, "scale", Vector2(1.12, 1.12), 0.18)
	tween.tween_property(label, "modulate:a", 0.0, 0.30); tween.tween_callback(label.queue_free)
