extends Plugin

var rect: TextureRect


func load_plugin():
	rect = UpdateSpinner.new()
	rect.size_flags_vertical = Control.SIZE_EXPAND | Control.SIZE_SHRINK_CENTER
	var icon_file = FileAccess.open(get_path() + "/icons/update_spinner.svg", FileAccess.READ)
	if icon_file:
		add_theme_icon("UpdateSpinner", icon_file.get_as_text())
		EditorTheme.get_singleton().add_to_icon_queue(rect, "texture", "UpdateSpinner")
	rect.hframes = 8
	rect.name = "UpdateSpinner"
	add_control_to_main_menu(rect, get_plugin_info(), Node.INTERNAL_MODE_BACK)


func unload_plugin():
	EditorTheme.get_singleton().remove_from_icon_queue(rect, "texture", "UpdateSpinner")
	remove_theme_icon("UpdateSpinner")
	remove_control_from_main_menu(rect)
	rect.free()


func get_plugin_info():
	return "Spins when the editor redraws."


class UpdateSpinner:
	extends TextureRect

	var frames_drawn := 0
	var step := 0


	func _process(_delta: float) -> void:
		var frames =  Engine.get_frames_drawn()
		var tick = Time.get_ticks_msec()
		if frames_drawn != frames and (tick - step) > 100:
			frames_drawn = frames + 1
			frame = wrapi(frame + 1, 0, hframes)
			step = tick
