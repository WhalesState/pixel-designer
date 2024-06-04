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
	TOP_LEFT_CONTAINER = 0,
	TOP_RIGHT_CONTAINER = 1,
	TOP_LEFT_DOCK = 2,
	BOTTOM_LEFT_DOCK = 3,
	TOP_RIGHT_DOCK = 4,
	BOTTOM_RIGHT_DOCK = 5,
}

var VERSION = ProjectSettings.get_setting_with_override("application/config/version")

## popups
var create_project_window := CreateProjectWindow.new(self)

## The base panel container which contains all the editor GUI.
var gui_base := PanelContainer.new()
var main_vbox := VBoxContainer.new()
var top_left_hbox := HBoxContainer.new()
var _main_screen_buttons := HBoxContainer.new()
var top_right_hbox := HBoxContainer.new()

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
	# GUI
	gui_base.name = "GuiBase"
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	gui_base.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	gui_base.theme_type_variation = "GuiBase"
	add_child(gui_base)
	main_vbox.name = "MainVBox"
	gui_base.add_child(main_vbox)
	var top_menu_hbox := HBoxContainer.new()
	top_menu_hbox.name = "TopMenuHBox"
	top_menu_hbox.add_theme_constant_override("separation", 0)
	main_vbox.add_child(top_menu_hbox)
	top_left_hbox.name = "TopLeftHBox"
	top_menu_hbox.add_child(top_left_hbox)
	top_menu_hbox.add_spacer(false)
	_main_screen_buttons.name = "MainScreenButtons"
	top_menu_hbox.add_child(_main_screen_buttons)
	top_menu_hbox.add_spacer(false)
	top_right_hbox.name = "TopRightHBox"
	top_menu_hbox.add_child(top_right_hbox)

	var main_split := Splitter.new([0.25, 0.75])
	main_split.name = "MainSplit"
	main_split.size_flags_vertical = SIZE_EXPAND_FILL
	var left_split := Splitter.new()
	left_split.name = "LeftSplit"
	left_split.vertical = true
	left_split.add_child(top_left_dock)
	left_split.add_child(bottom_left_dock)
	main_split.add_child(left_split)
	var center_split := Splitter.new([0.6])
	center_split.name = "CenterSplit"
	center_split.vertical = true
	center_split.add_child(center_dock)
	center_split.add_child(bottom_dock)
	main_split.add_child(center_split)
	var right_split := Splitter.new()
	right_split.name = "RightSplit"
	right_split.vertical = true
	right_split.add_child(top_right_dock)
	right_split.add_child(bottom_right_dock)
	bottom_right_dock.hide()
	main_split.add_child(right_split)
	main_vbox.add_child(main_split)

	#var left_split := HSplitContainer.new()
	#left_split.name = "LeftSplit"
	#left_split.add_theme_constant_override("autohide", 0)
	## left_split.split_offset = 128
	#left_split.size_flags_vertical = SIZE_EXPAND_FILL
	#main_vbox.add_child(left_split)
	#var left_vsplit := VSplitContainer.new()
	#left_vsplit.name = "LeftVSplit"
	#left_vsplit.size_flags_horizontal = SIZE_EXPAND_FILL
	#left_split.add_child(left_vsplit)
	#var right_split := HSplitContainer.new()
	#right_split.name = "RightSplit"
	#right_split.add_theme_constant_override("autohide", 0)
	#right_split.size_flags_horizontal = SIZE_EXPAND_FILL
	#left_split.add_child(right_split)
	#var center_vsplit := VSplitContainer.new()
	#center_vsplit.name = "CenterVSplit"
	#center_vsplit.size_flags_horizontal = SIZE_EXPAND_FILL
	#right_split.add_child(center_vsplit)
	#var right_vsplit := VSplitContainer.new()
	#right_vsplit.name = "RightVSplit"
	#right_vsplit.size_flags_horizontal = SIZE_EXPAND_FILL
	#right_split.add_child(right_vsplit)
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
	# OS.shell_open(user_dir.get_current_dir())
	# Load Recent project if exists.
	var recent_project = editor_settings.get_value("application", "recent", "")
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
		Base.TOP_LEFT_CONTAINER:
			return top_left_hbox
		Base.TOP_RIGHT_CONTAINER:
			return top_right_hbox
		Base.TOP_LEFT_DOCK:
			return null
		Base.BOTTOM_LEFT_DOCK:
			return null
		Base.TOP_RIGHT_DOCK:
			return null
		Base.BOTTOM_RIGHT_DOCK:
			return null
		_:
			return null


func save_editor_settings():
	if editor_settings.get_sections().size() == 0:
		editor_settings.set_value("application", "version", VERSION)
		editor_settings.set_value("application", "recent", "")
	editor_settings.save(OS.get_user_data_dir() + "/editor_settings.cfg")


func save_project_settings():
	project_settings.save(project_dir.get_current_dir() + "/project.cfg")
