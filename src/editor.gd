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

class_name Editor
extends Control

## The Editor control node.
##
## [color=yellow]Warning:[/color] Don't use [Editor] class directly,
## instead, it can be accessed from any node by using the autoload keyword [color=light_green]E[/color] if the node is inisde tree, [method Node.is_inside_tree].
##[codeblock]
##func _enter_tree():
##    print(E.gui_base)
##[/codeblock]

## List of all the Editor Containers that can be used with [method add_control] or [method remove_control].
enum Base {
	TOP_RIGHT_CONTAINER = 0,
	TOP_LEFT_DOCK = 1,
	BOTTOM_LEFT_DOCK = 2,
	TOP_RIGHT_DOCK = 3,
	BOTTOM_RIGHT_DOCK = 4,
	BOTTOM_DOCK = 5,
}

## The current version for PixelDesigner.
var VERSION = ProjectSettings.get_setting_with_override("application/config/version")

## popups
var create_project_window := CreateProjectWindow.new(self)
var editor_settings_window := EditorSettingsWindow.new(self)
var project_settings_window := ProjectSettingsWindow.new(self)

## The base panel container which contains all the editor GUI.
var gui_base := PanelContainer.new()
var main_vbox := VBoxContainer.new()
var top_menu := HBoxContainer.new()
var _main_screen_buttons := HBoxContainer.new()
var _main_screen_button_group := ButtonGroup.new()
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

## The main [ImageEditor].
var image_editor: ImageEditor
var node_tree: NodeTree

## The projects directory inside user data directory.
var projects_dir: DirAccess
## The plugins directory inside user data directory.
var plugins_dir: DirAccess
## ConfigFile for saving editor settings file.
var editor_settings := ConfigFile.new()
## A list of all project plugins.
var plugin_list := {}

## The current project directory.
var project_dir: DirAccess
## ConfigFile for saving project settings file.
var project_settings := ConfigFile.new()

## The Editor undo/redo manager.
var undo_redo = UndoRedo.new()


## Used instead of builtin [method Node._ready] to allow doc comments.
func ready() -> void:
	_load_plugins()
	get_tree().get_root().min_size = gui_base.get_minimum_size()
	image_editor.call_deferred("center_view")


## Used for editor key input.
func key_input(k: InputEventKey) -> bool:
	if not k.is_pressed():
		return false
	if k.keycode == KEY_Z and k.is_command_or_control_pressed():
		if k.shift_pressed:
			undo_redo.redo()
		else:
			undo_redo.undo()
		return true
	if k.is_echo():
		return false
	if k.keycode == KEY_S and k.is_command_or_control_pressed():
		if k.shift_pressed:
			create_project_window.title = "Save Project As.."
			create_project_window.show_size_settings(true)
			create_project_window.popup_centered()
		else:
			save()
		return true
	return false


## Used instead of builtin [method Node._exit_tree] to allow doc comments.
func exit_tree() -> void:
	_unload_plugins()
	for plugin in plugin_list.values():
		plugin.free()
	undo_redo.free()
	save_editor_settings()


## Check if a plugin is enabled using it's name.
func is_plugin_enabled(plugin: String) -> bool:
	return editor_settings.get_value("editor", "enabled_plugins", []).has(plugin)


## Enable a plugin using it's name.
func enable_plugin(plugin: String) -> void:
	_set_plugin_enabled(plugin, true)


## Disable a plugin using it's name.
func disable_plugin(plugin: String) -> void:
	_set_plugin_enabled(plugin, false)


## Save the project and it's settings.
func save() -> void:
	if project_dir:
		var vp_size = get_viewport_size()
		project_settings.set_value("project", "view_width", vp_size.x)
		project_settings.set_value("project", "view_height", vp_size.y)
		project_settings.set_value("project", "snap_2d_transforms_to_pixel", image_editor.root.snap_2d_transforms_to_pixel)
		project_settings.set_value("project", "snap_2d_vertices_to_pixel", image_editor.root.snap_2d_vertices_to_pixel)
		save_project_settings()
	else:
		create_project_window.title = "Save Project"
		create_project_window.show_size_settings(false)
		create_project_window.popup_centered()


#TODO: Reload project!
## Force reload the current project.
func reload_project() -> void:
	pass


## Returns the current root size.
func get_viewport_size() -> Vector2:
	if image_editor:
		return image_editor.root.size
	else:
		print("ERROR: ImageEditor root is not accessible. Returning default size (32, 32).")
		return Vector2(32, 32)


## Add a new [MenuButton] to the top menu and returns it's child index.
func add_menu(menu_name: String, menu_button: MenuButton) -> int:
	menu_button.name = menu_name.capitalize()
	menu_button.text = menu_name
	menu_button.focus_mode = FOCUS_NONE
	menu_button.switch_on_hover = true
	top_menu.add_child(menu_button)
	menu_button.get_popup().id_pressed.connect(_on_menu_id_pressed.bind(menu_name, menu_button.get_popup()))
	return menu_button.get_index()


## Remove a [MenuButton] from top menu.
func remove_menu(menu_button: MenuButton) -> void:
	top_menu.remove_child(menu_button)
	menu_button.queue_free()


## Adds a control node to the editor.
func add_control(control: Control, base: Base) -> void:
	var container = get_container(base)
	if container:
		if container.has_node(str(control.name)):
			var _idx = 1
			while container.has_node(str(control.name) + str(_idx)):
				_idx += 1
			control.name = str(control.name) + str(_idx)
		container.add_child(control)


## Removes a control node from the editor.
func remove_control(control: Control, base: Base) -> void:
	var container = get_container(base)
	if container:
		container.remove_child(control)


## Adds a control to the main center node of the editor. [member Node.name] will be used for the generated node button's text.
func add_center_control(control: Control, icon: Texture2D, custom_name := "") -> void:
	if not control:
		return
	var _name := ""
	if custom_name.is_empty():
		_name = control.name
	else:
		_name = custom_name
	var button = Button.new()
	button.name = _name
	button.text = _name.capitalize()
	button.icon = icon
	button.flat = true
	button.toggle_mode = true
	button.button_group = _main_screen_button_group
	button.theme_type_variation = "MainScreenButton"
	if _main_screen_buttons.get_child_count() == 0:
		button.button_pressed = true
	_main_screen_buttons.add_child(button)
	button.pressed.connect(func(idx := button.get_index()):
		center_dock.current_tab = idx
	)
	control.set_meta("button", button)
	center_dock.add_child(control)


## Remove a center control from main screen plugins, and it's button.
func remove_center_control(control: Control) -> void:
	if not control:
		return
	var button = control.get_meta("button")
	_main_screen_buttons.remove_child(button)
	button.queue_free()
	center_dock.remove_child(control)
	if center_dock.current_tab != -1:
		center_dock.get_tab_control(center_dock.current_tab).get_meta("button").button_pressed = true


## Returns the specific editor container, use enum [enum Base] as a hint.
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


## Saves new editor_settings.cfg file with default values in user data directory
## if it's empty, or the existing one will be saved.
func save_editor_settings() -> void:
	if editor_settings.get_sections().size() == 0:
		editor_settings.set_value("editor", "version", VERSION)
		editor_settings.set_value("editor", "recent", "")
		editor_settings.set_value("editor", "loaded_plugins", [])
		editor_settings.set_value("editor", "enabled_plugins", [])
		editor_settings.set_value("editor", "left_split_offset", 0.2)
		editor_settings.set_value("editor", "center_split_offset", 0.8)
		editor_settings.set_value("editor", "center_dock_offset", 0.7)
		editor_settings.set_value("editor", "top_left_dock_offset", 0.6)
		editor_settings.set_value("editor", "top_right_split_offset", 0.6)
		editor_settings.set_value("editor", "show_grid", true)
		editor_settings.set_value("editor", "show_rulers", true)
		editor_settings.set_value("editor", "show_guides", true)
		editor_settings.set_value("editor", "grid_offset", Vector2.ZERO)
		editor_settings.set_value("editor", "grid_step", Vector2(16, 16))
		editor_settings.set_value("editor", "primary_grid_step", Vector2i(8, 8))
	else:
		editor_settings.set_value("editor", "left_split_offset", left_split.get_meta("dragger_offset", 0.2))
		editor_settings.set_value("editor", "center_split_offset", center_split.get_meta("dragger_offset", 0.8))
		editor_settings.set_value("editor", "center_dock_offset", center_dock.get_meta("dragger_offset", 0.7))
		editor_settings.set_value("editor", "top_left_dock_offset", top_left_dock.get_meta("dragger_offset", 0.6))
		editor_settings.set_value("editor", "top_right_dock_offset", top_right_dock.get_meta("dragger_offset", 0.6))
	editor_settings.save(OS.get_user_data_dir() + "/editor_settings.cfg")


## Saves project_settings.cfg file to the current project folder.
func save_project_settings() -> void:
	if project_dir:
		project_settings.save(project_dir.get_current_dir() + "/project.cfg")


# Calls [method ready].
func _ready() -> void:
	ready()


# Calls [method key_input].
func _input(ev: InputEvent) -> void:
	var accepted := false
	var k: InputEventKey = ev as InputEventKey
	if k:
		accepted = key_input(k)
	if accepted:
		get_viewport().set_input_as_handled()


# Calls [method exit_tree].
func _exit_tree() -> void:
	exit_tree()


# Packs all plugins into a Pck file and saves it in user data plugins folder.
func _pack_plugins() -> void:
	var internal_plugins_dir = DirAccess.open("res://plugins")
	if internal_plugins_dir:
		for plugin in internal_plugins_dir.get_directories():
			var plugin_path = internal_plugins_dir.get_current_dir() + "/" + plugin
			var files = MISC.get_dir_files(plugin_path)
			if files.size() > 0:
				var pck := PCKPacker.new()
				pck.pck_start(plugins_dir.get_current_dir() + "/" + plugin + ".pck")
				for file in files:
					pck.add_file(file.replace("res://plugins/", "res://loaded_plugins/") , file)
				pck.flush(true)


# Load all plugins by calling their [method Plugin.load_plugin] method if they are enabled.
func _load_plugins() -> void:
	plugins_dir.list_dir_begin()
	var file_name = plugins_dir.get_next()
	while file_name != "":
		if file_name.get_extension() == "pck":
			ProjectSettings.load_resource_pack(plugins_dir.get_current_dir() + "/" + file_name)
		file_name = plugins_dir.get_next()
	plugins_dir.list_dir_end()
	var loaded_plugins = DirAccess.open("res://loaded_plugins")
	var enabled_plugins = editor_settings.get_value("editor", "enabled_plugins", [])
	if loaded_plugins:
		for plugin in loaded_plugins.get_directories():
			var plugin_path = loaded_plugins.get_current_dir() + "/" + plugin
			if loaded_plugins.file_exists(plugin + "/plugin.gd"):
				var plugin_script = load(plugin_path + "/plugin.gd").new()
				plugin_list[plugin] = plugin_script
				if enabled_plugins.has(plugin):
					plugin_script.load_plugin()
	editor_settings.set_value("editor", "loaded_plugins", plugin_list.keys())
	save_editor_settings()


# Unload all plugins by calling their [method Plugin.unload_plugin] method if they are enabled.
func _unload_plugins() -> void:
	var enabled_plugins = editor_settings.get_value("editor", "enabled_plugins", [])
	for plugin in enabled_plugins:
		plugin_list[plugin].unload_plugin()


# Sets a plugin enabled or disabled.
func _set_plugin_enabled(plugin: String, enabled: bool) -> void:
	if not plugin_list.keys().has(plugin):
		return
	var enabled_plugins = editor_settings.get_value("editor", "enabled_plugins", [])
	if enabled:
		if enabled_plugins.has(plugin):
			return
		enabled_plugins.append(plugin)
		editor_settings.set_value("editor", "enabled_plugins", enabled_plugins)
		plugin_list[plugin].load_plugin()
	else:
		if not enabled_plugins.has(plugin):
			return
		enabled_plugins.erase(plugin)
		editor_settings.set_value("editor", "enabled_plugins", enabled_plugins)
		plugin_list[plugin].unload_plugin()
	save_editor_settings()


func _on_menu_id_pressed(_id: int, _name: String, _menu: PopupMenu) -> void:
	var item_name: String = _menu.get_item_text(_id)
	match _name:
		"Project":
			match item_name:
				"Save Project":
					save()
				"Save Project As...":
					create_project_window.title = "Save Project As..."
					create_project_window.show_size_settings(true)
					create_project_window.popup_centered()
				"Open Project":
					pass
				"Project Settings":
					project_settings_window.popup_centered()
				"Exit":
					get_tree().quit()
		"Editor":
			match item_name:
				"Editor Settings":
					editor_settings_window.popup_centered()
		"Help":
			pass
		_:
			print("Unknown menu: " + _name, " : ", item_name)
	prints(_name, item_name)


func _init() -> void:
	# Get or create projects directory.
	var user_dir := DirAccess.open(OS.get_user_data_dir())
	if user_dir:
		if not user_dir.dir_exists("projects"):
			user_dir.make_dir("projects")
		projects_dir = DirAccess.open(OS.get_user_data_dir() + "/projects")
		if not user_dir.dir_exists("plugins"):
			user_dir.make_dir("plugins")
		plugins_dir = DirAccess.open(OS.get_user_data_dir() + "/plugins")
	# Get or create editor_settings.cfg.
	if user_dir.file_exists("editor_settings.cfg"):
		editor_settings.load(user_dir.get_current_dir() + "/editor_settings.cfg")
		# Apply version changes. should be done in a new script, to loop from the first version to the latest and apply changes.
		if editor_settings.get_value("editor", "version", "0.0.0") != VERSION:
			pass
	else:
		save_editor_settings()
	# pack plugins
	if OS.is_debug_build():
		_pack_plugins()
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
	center_dock.tabs_visible = false
	center_split.add_child(center_dock)
	center_split.add_child(bottom_dock)
	main_split.add_child(center_split)
	right_split.name = "RightSplit"
	right_split.vertical = true
	split_offset = editor_settings.get_value("editor", "top_right_dock_offset", 0.6)
	top_right_dock.set_meta("dragger_offset", split_offset)
	right_split.add_child(top_right_dock)
	right_split.add_child(bottom_right_dock)
	main_split.add_child(right_split)
	main_vbox.add_child(main_split)
	# Load Recent project if exists.
	var recent_project = editor_settings.get_value("editor", "recent", "")
	if not recent_project.is_empty():
		project_dir = DirAccess.open(projects_dir.get_current_dir() + "/" + recent_project)
		project_settings.load(projects_dir.get_current_dir() + "/" + recent_project + "/project.cfg")
	# Add controls to the editor.
	image_editor = ImageEditor.new(self)
	add_center_control(image_editor, preload("res://icons/image_editor.svg"))
	node_tree = NodeTree.new(self)
	add_control(node_tree, Base.TOP_LEFT_DOCK)
	# Popups
	add_child(create_project_window)
	add_child(editor_settings_window)
	add_child(project_settings_window)
	# Menus
	var project_menu := MenuButton.new()
	project_menu.get_popup().add_item("Save Project")
	project_menu.get_popup().add_item("Save Project As...")
	project_menu.get_popup().add_item("Open Project")
	project_menu.get_popup().add_item("Project Settings")
	project_menu.get_popup().add_item("Exit")
	add_menu("Project", project_menu)
	var editor_menu := MenuButton.new()
	editor_menu.get_popup().add_item("Editor Settings")
	add_menu("Editor", editor_menu)
	var help_menu := MenuButton.new()
	add_menu("Help", help_menu)
