class_name Editor
extends MarginContainer

## The projects directory inside user data directory.
var projects_dir: DirAccess

## The plugins directory inside user data directory.
var plugins_dir: DirAccess

## A list of all project plugins.
var plugin_list := {}

## The current project directory.
var project_dir: DirAccess

## The Editor undo/redo manager.
var undo_redo = UndoRedo.new()

var scene := preload("res://scene/editor.tscn").instantiate()

var top_left_container: HBoxContainer = scene.get_node("%MenuLeftHBox")
var top_center_container: HBoxContainer = scene.get_node("%MenuCenterHBox")
var top_right_container: HBoxContainer = scene.get_node("%MenuRightHBox")
var top_left_dock: TabContainer = scene.get_node("%TopLeftDock")
var bottom_left_dock: TabContainer = scene.get_node("%BottomLeftDock")
var center_dock: TabContainer = scene.get_node("%CenterDock")
var bottom_dock: TabContainer = scene.get_node("%BottomDock")
var top_right_dock: TabContainer = scene.get_node("%TopRightDock")
var bottom_right_dock: TabContainer = scene.get_node("%BottomRightDock")

static var singleton: Editor


static func get_singleton() -> Editor:
	return singleton


func get_dir_files(path: String) -> Array:
	var files := []
	var dir = DirAccess.open(path)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "": 
			if dir.current_is_dir():
				files.append_array(get_dir_files(dir.get_current_dir() + "/" + file_name))
			else:
				files.append(dir.get_current_dir() + "/" + file_name)
			file_name = dir.get_next()
		dir.list_dir_end()
	return files


# Packs all plugins into a Pck file and saves it in user data plugins folder.
func _pack_plugins() -> void:
	var dir = DirAccess.open("res://plugins")
	if dir:
		for plugin in dir.get_directories():
			var plugin_path = dir.get_current_dir() + "/" + plugin
			var files = get_dir_files(plugin_path)
			if files.size() > 0:
				var pck := PCKPacker.new()
				pck.pck_start("res://plugins/" + plugin + ".pixel_plugin")
				for file in files:
					pck.add_file(file.replace("res://plugins/", "res://loaded_plugins/") , file)
				pck.flush(true)


# Load all plugins by calling their [method Plugin.load_plugin] method if they are enabled.
func _load_plugins() -> void:
	var files = DirAccess.get_files_at("res://plugins")
	var dir = DirAccess.open("res://plugins")
	for file in files:
		if file.get_extension() != "pixel_plugin":
			continue
		if OS.has_feature("editor"):
			if not dir.dir_exists(file.get_basename()):
				dir.remove(file)
				continue
		ProjectSettings.load_resource_pack(dir.get_current_dir() + "/" + file)
	files = DirAccess.get_files_at(OS.get_user_data_dir() + "/plugins")
	for file in files:
		if file.get_extension() == "pixel_plugin":
			ProjectSettings.load_resource_pack(OS.get_user_data_dir() + "/plugins/" + file)
	var loaded_plugins = DirAccess.open("res://loaded_plugins")
	if loaded_plugins:
		var enabled_plugins: Array = Settings.get_singleton().get_editor_value("editor", "enabled_plugins", [])
		for plugin in loaded_plugins.get_directories():
			var plugin_path = loaded_plugins.get_current_dir() + "/" + plugin
			if loaded_plugins.file_exists(plugin + "/plugin.gd"):
				var plugin_script: Plugin = load(plugin_path + "/plugin.gd").new()
				plugin_script._path = plugin_path
				plugin_list[plugin] = plugin_script
				if plugin_script.is_internal() || enabled_plugins.has(plugin):
					plugin_script.load_plugin()
		var to_remove := PackedInt32Array([])
		for i in enabled_plugins.size():
			if not plugin_list.keys().has(enabled_plugins[i]):
				to_remove.append(i)
		var removed := 0
		for i in to_remove:
			enabled_plugins.remove_at(i - removed)
			removed += 1
		Settings.get_singleton().set_editor_value("editor", "enabled_plugins", enabled_plugins)
	Settings.get_singleton().set_editor_value("editor", "loaded_plugins", plugin_list.keys())
	


# Unload all plugins by calling their [method Plugin.unload_plugin] method if they are enabled.
func _unload_plugins() -> void:
	var enabled_plugins = Settings.get_singleton().get_editor_value("editor", "enabled_plugins", [])
	for plugin_name in plugin_list.keys():
		var plugin = plugin_list[plugin_name]
		if plugin.is_internal() || enabled_plugins.has(plugin_name):
			plugin.unload_plugin()


# Sets a plugin enabled or disabled.
func _set_plugin_enabled(plugin_name: String, enabled: bool) -> void:
	if not plugin_list.keys().has(plugin_name):
		return
	var enabled_plugins = Settings.get_singleton().get_editor_value("editor", "enabled_plugins", [])
	var plugin: Plugin = plugin_list[plugin_name]
	if plugin.is_internal():
		return
	if enabled:
		if enabled_plugins.has(plugin_name):
			return
		enabled_plugins.append(plugin_name)
		plugin.load_plugin()
	else:
		if not enabled_plugins.has(plugin_name):
			return
		enabled_plugins.erase(plugin_name)
		plugin.unload_plugin()
	Settings.get_singleton().set_editor_value("editor", "enabled_plugins", enabled_plugins)


## Check if a plugin is enabled using it's name.
func is_plugin_enabled(plugin_name: String) -> bool:
	if not plugin_list.keys().has(plugin_name):
		return false
	if plugin_list[plugin_name].is_internal():
		return true
	return Settings.get_singleton().get_editor_value("editor", "enabled_plugins", []).has(plugin_name)


## Enable a plugin using it's name.
func enable_plugin(plugin: String) -> void:
	if not is_plugin_enabled(plugin):
		_set_plugin_enabled(plugin, true)


## Disable a plugin using it's name.
func disable_plugin(plugin: String) -> void:
	if is_plugin_enabled(plugin):
		_set_plugin_enabled(plugin, false)


func _ready() -> void:
	Root.get_singleton().min_size = get_minimum_size()


func _enter_tree() -> void:
	_load_plugins()


func _exit_tree() -> void:
	_unload_plugins()
	for plugin in plugin_list.values():
		plugin.free()


func _init():
	print_debug("Editor _init()")
	name = "Editor"
	set_margin_all(2)
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	# Get or create projects directory.
	var user_dir := DirAccess.open(OS.get_user_data_dir())
	if user_dir:
		if not user_dir.dir_exists("projects"):
			user_dir.make_dir("projects")
		projects_dir = DirAccess.open(OS.get_user_data_dir() + "/projects")
		if not user_dir.dir_exists("plugins"):
			user_dir.make_dir("plugins")
		plugins_dir = DirAccess.open(OS.get_user_data_dir() + "/plugins")
	# Pack plugins.
	if OS.has_feature("editor"):
		_pack_plugins()
	# Load editor interface.
	add_child(scene)
	var editor_theme = EditorTheme.get_singleton()
	var settings = Settings.get_singleton()
	var btn_expand_left: Button = scene.get_node("%ButtonExpandLeft")
	editor_theme.add_to_icon_queue(btn_expand_left, "normal_icon", "GuiLeft")
	editor_theme.add_to_icon_queue(btn_expand_left, "pressed_icon", "GuiRight")
	var btn_expand_right: Button = scene.get_node("%ButtonExpandRight")
	editor_theme.add_to_icon_queue(btn_expand_right, "normal_icon", "GuiRight")
	editor_theme.add_to_icon_queue(btn_expand_right, "pressed_icon", "GuiLeft")
	var btn_expand_bottom_left: Button = scene.get_node("%ButtonExpandBottomLeft")
	var btn_expand_bottom: Button = scene.get_node("%ButtonExpandBottom")
	var btn_expand_bottom_right: Button = scene.get_node("%ButtonExpandBottomRight")
	for button in [btn_expand_bottom_left, btn_expand_bottom, btn_expand_bottom_right]:
		editor_theme.add_to_icon_queue(button, "normal_icon", "GuiDown")
		editor_theme.add_to_icon_queue(button, "pressed_icon", "GuiUp")
	var btn_about: Button = scene.get_node("%ButtonAbout")
	editor_theme.add_to_icon_queue(btn_about, "icon", "GuiInfo")
	var btn_help: Button = scene.get_node("%ButtonHelp")
	editor_theme.add_to_icon_queue(btn_help, "icon", "GuiHelp")
	const split_names: PackedStringArray = ["MainSplit", "LeftSplit", "CenterSplit", "RightSplit"]
	const offsets := [[0.2, 0.8], [0.6], [0.7], [0.6]]
	for i in split_names.size():
		var node: SplitterContainer = scene.get_node("%" + split_names[i])
		var offset := split_names[i].to_snake_case() + "_offsets"
		node.set_offsets(settings.get_editor_value("ui", offset, offsets[i]))
		node.offsets_changed.connect(func():
			settings.set_editor_value("ui", offset, node.get_offsets())
		)
	# Final pass.
	singleton = self
