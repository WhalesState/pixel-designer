@tool
extends Control

var project_file: ConfigFile
var project_dir: DirAccess


func _init():
	MISC._prepare()


func _input(ev: InputEvent):
	if Engine.is_editor_hint():
		if not is_visible_in_tree():
			return
	if not (ev is InputEventKey and ev.pressed and not ev.echo):
		return
	if ev.keycode == KEY_S:
		if ev.ctrl_pressed:
			if ev.shift_pressed:
				get_node("%Popups").project_name_window.popup()
			else:
				save_project()
			get_viewport().set_input_as_handled()
	elif ev.keycode == KEY_Z:
		if ev.ctrl_pressed:
			if ev.shift_pressed:
				G.undo_redo.redo()
				pass
			else:
				G.undo_redo.undo()
				pass
			get_viewport().set_input_as_handled()


func save_project():
	if project_file:
		project_file.set_value("data", "size", get_node("%Viewport").size)
		if not OK == project_file.save(project_dir.get_current_dir() + "/project.cfg"):
			print("Warning: Can't save project file")
			MISC._prepare()
			get_node("%Popups").project_name_window.popup()
	else:
		get_node("%Popups").project_name_window.popup()
