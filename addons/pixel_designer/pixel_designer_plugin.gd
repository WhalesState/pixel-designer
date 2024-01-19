@tool
extends EditorPlugin

const MainScene = preload("res://main.tscn")

var pixel_designer


func _enter_tree():
	pixel_designer = MainScene.instantiate()
	get_editor_interface().get_editor_main_screen().add_child(pixel_designer)
	_make_visible(false)


func _exit_tree():
	if pixel_designer:
		pixel_designer.queue_free()


func _has_main_screen():
	return true


func _make_visible(visible: bool):
	if pixel_designer:
		pixel_designer.visible = visible


func _get_plugin_name():
	return "PD"
