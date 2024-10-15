extends Plugin

var pixel_editor: Control


func load_plugin() -> void:
	pixel_editor = Control.new()
	pixel_editor.name = "PixelEditor"
	add_control_to_main_screen(pixel_editor, "PixelEditor", get_plugin_info())


func unload_plugin() -> void:
	remove_control_from_main_screen(pixel_editor)
	pixel_editor.free()


func get_plugin_info() -> String:
	return "Allows you to edit pixel images."


func get_plugin_version() -> String:
	return "0.0.1"


func can_exit() -> bool:
	return true

