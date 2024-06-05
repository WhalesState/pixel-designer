"""*********************************************************************
*                        This file is Part of                          *
*                           Pixel Designer                             *
************************************************************************
* Copyright (c) 2023-present (Erlend Sogge Heggen), (Mounir Tohami).   *
* License : PolyForm Strict License 1.0.0                              *
* https://polyformproject.org/licenses/strict/1.0.0                    *
* Made with : Pixel Engine (Godot Engine hard fork)                    *
* https://github.com/WhalesState/godot-pixel-engine                    *
*********************************************************************"""

extends Control

## The Editor control node.
##
## [color=yellow]Warning:[/color] Don't use [Editor] class directly,
## instead, it can be accessed from any node by using if [method Node.is_inside_tree].
##[codeblock]
##func _enter_tree():
##    print(Editor.gui_base)
##[/codeblock]

enum Base {
	TOP_RIGHT_CONTAINER = 0,
	TOP_LEFT_DOCK = 1,
	BOTTOM_LEFT_DOCK = 2,
	TOP_RIGHT_DOCK = 3,
	BOTTOM_RIGHT_DOCK = 4,
	BOTTOM_DOCK = 5,
}

var VERSION = ProjectSettings.get_setting_with_override("application/config/version")

## popups
var create_project_window := CreateProjectWindow.new(self)

## The base panel container which contains all the editor GUI.
var gui_base := PanelContainer.new()
var main_vbox := VBoxContainer.new()
var top_menu := HBoxContainer.new()
var _main_screen_buttons := HBoxContainer.new()
var top_right_hbox := HBoxContainer.new()

var main_split := Splitter.new()
var left_split := Splitter.new()
var center_split := Splitter.new()
var right_split := Splitter.new()

var top_left_dock := TabContainer.new()
var bottom_left_dock := TabContainer.new()
var center_dock := TabContainer.new()
var bottom_dock := TabContainer.new()
var top_right_dock := TabContainer.new()
var bottom_right_dock := TabContainer.new()

var projects_dir: DirAccess
var editor_settings := ConfigFile.new()

var project_dir: DirAccess
var project_settings := ConfigFile.new()

var undo_redo = UndoRedo.new()


func _init():
	# Get or create projects directory.
	var user_dir := DirAccess.open(OS.get_user_data_dir())
	if user_dir:
		if user_dir.dir_exists("projects"):
			projects_dir = DirAccess.open(OS.get_user_data_dir() + "/projects")
		else:
			user_dir.make_dir("projects")
			projects_dir = DirAccess.open(OS.get_user_data_dir() + "/projects")
	# Get or create editor_settings.cfg.
	if user_dir.file_exists("editor_settings.cfg"):
		editor_settings.load(user_dir.get_current_dir() + "/editor_settings.cfg")
	else:
		save_editor_settings()
	# GUI
	gui_base.name = "GuiBase"
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	gui_base.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	gui_base.theme_type_variation = "GuiBase"
	add_child(gui_base)
	main_vbox.name = "MainVBox"
	gui_base.add_child(main_vbox)
	var top_hbox := HBoxContainer.new()
	top_hbox.name = "TopHBox"
	top_hbox.add_theme_constant_override("separation", 0)
	main_vbox.add_child(top_hbox)
	top_menu.name = "TopMenu"
	top_hbox.add_child(top_menu)
	top_hbox.add_spacer(false)
	_main_screen_buttons.name = "MainScreenButtons"
	top_hbox.add_child(_main_screen_buttons)
	top_hbox.add_spacer(false)
	top_right_hbox.name = "TopRightHBox"
	top_hbox.add_child(top_right_hbox)
	# Splitters and docks.
	main_split.name = "MainSplit"
	main_split.size_flags_vertical = SIZE_EXPAND_FILL
	left_split.name = "LeftSplit"
	var split_offset: float = editor_settings.get_value("editor", "left_split_offset", 0.2)
	left_split.set_meta("dragger_offset", split_offset)
	left_split.vertical = true
	split_offset = editor_settings.get_value("editor", "top_left_dock_offset", 0.6)
	top_left_dock.set_meta("dragger_offset", split_offset)
	left_split.add_child(top_left_dock)
	left_split.add_child(bottom_left_dock)
	main_split.add_child(left_split)
	center_split.name = "CenterSplit"
	split_offset = editor_settings.get_value("editor", "center_split_offset", 0.8)
	center_split.set_meta("dragger_offset", split_offset)
	center_split.vertical = true
	split_offset = editor_settings.get_value("editor", "center_dock_offset", 0.7)
	center_dock.set_meta("dragger_offset", split_offset)
	center_split.add_child(center_dock)
	center_split.add_child(bottom_dock)
	main_split.add_child(center_split)
	right_split.name = "RightSplit"
	right_split.vertical = true
	split_offset = editor_settings.get_value("editor", "top_right_dock_offset", 0.6)
	top_right_dock.set_meta("dragger_offset", split_offset)
	right_split.add_child(top_right_dock)
	right_split.add_child(bottom_right_dock)
	bottom_right_dock.hide()
	main_split.add_child(right_split)
	main_vbox.add_child(main_split)

	# OS.shell_open(user_dir.get_current_dir())
	# Load Recent project if exists.
	var recent_project = editor_settings.get_value("editor", "recent", "")
	if not recent_project.is_empty():
		project_dir = DirAccess.open(projects_dir.get_current_dir() + "/" + recent_project)
		project_settings.load(projects_dir.get_current_dir() + "/" + recent_project + "/project.cfg")
		reload_project()
	# Popups
	add_child(create_project_window)


func _input(ev: InputEvent) -> void:
	var k: InputEventKey = ev as InputEventKey
	if k and not k.is_echo():
		if k.keycode == KEY_S and k.is_command_or_control_pressed():
			if k.shift_pressed:
				create_project_window.title = "Save Project As.."
				create_project_window.popup_centered()
			else:
				save()
			get_viewport().set_input_as_handled()
		elif k.keycode == KEY_Z and k.is_command_or_control_pressed():
			if k.shift_pressed:
				print("Redo")
			else:
				print("Undo")
			get_viewport().set_input_as_handled()


func _ready():
	get_tree().get_root().min_size = gui_base.get_minimum_size()
	# create_project_window.popup_centered()


func _exit_tree():
	save_editor_settings()


func save():
	if project_dir:
		project_settings.set_value("project", "size", get_viewport_size())
		save_project_settings()
	else:
		create_project_window.title = "Save Project"
		create_project_window.popup_centered()


func reload_project():
	pass


func get_viewport_size() -> Vector2:
	return Vector2(16, 16)


func add_menu(menu_name: String, menu_button: MenuButton) -> int:
	menu_button.name = menu_name.capitalize()
	menu_button.text = menu_name
	top_menu.add_child(menu_button)
	return menu_button.get_index()


func remove_menu(menu_button: MenuButton) -> void:
	top_menu.remove_child(menu_button)
	menu_button.queue_free()


## Adds a control node to the editor.
func add_control(control: Control, base: Base):
	var container = get_container(base)
	if container:
		container.add_child(control)


## Removes a control node from the editor.
func remove_control(control: Control, base: Base):
	var container = get_container(base)
	if container:
		container.remove_child(control)


func get_container(base: Base) -> Control:
	match base:
		Base.TOP_RIGHT_CONTAINER:
			return top_right_hbox
		Base.TOP_LEFT_DOCK:
			return top_left_dock
		Base.BOTTOM_LEFT_DOCK:
			return bottom_left_dock
		Base.TOP_RIGHT_DOCK:
			return top_right_dock
		Base.BOTTOM_RIGHT_DOCK:
			return bottom_right_dock
		Base.BOTTOM_DOCK:
			return bottom_dock
		_:
			return null


func save_editor_settings():
	if editor_settings.get_sections().size() == 0:
		editor_settings.set_value("editor", "version", VERSION)
		editor_settings.set_value("editor", "recent", "")
		editor_settings.set_value("editor", "left_split_offset", 0.2)
		editor_settings.set_value("editor", "center_split_offset", 0.8)
		editor_settings.set_value("editor", "center_dock_offset", 0.7)
		editor_settings.set_value("editor", "top_left_dock_offset", 0.6)
		editor_settings.set_value("editor", "top_right_split_offset", 0.6)
	else:
		editor_settings.set_value("editor", "version", VERSION)
		editor_settings.set_value("editor", "left_split_offset", left_split.get_meta("dragger_offset", 0.2))
		editor_settings.set_value("editor", "center_split_offset", center_split.get_meta("dragger_offset", 0.8))
		editor_settings.set_value("editor", "center_dock_offset", center_dock.get_meta("dragger_offset", 0.7))
		editor_settings.set_value("editor", "top_left_dock_offset", top_left_dock.get_meta("dragger_offset", 0.6))
		editor_settings.set_value("editor", "top_right_dock_offset", top_right_dock.get_meta("dragger_offset", 0.6))
	editor_settings.save(OS.get_user_data_dir() + "/editor_settings.cfg")


func save_project_settings():
	project_settings.save(project_dir.get_current_dir() + "/project.cfg")
