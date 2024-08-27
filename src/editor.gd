class_name Editor
extends MarginContainer

## [b]PRIVATE[/b] The plugins directory inside user data directory.
var _plugins_dir: DirAccess

## [b]PRIVATE[/b] A list of all project plugins.
var _plugin_list := {}

## [b]PRIVATE[/b] The editor gui scene.
var _scene := preload("res://scene/editor.tscn").instantiate()

var _main_menu: HBoxContainer = _scene.get_node("%MainMenu")
var _main_hbox: HBoxContainer = _scene.get_node("%MainHBox")
var _side_menu: VBoxContainer = _scene.get_node("%SideMenu")
var _main_screen: MarginContainer = _scene.get_node("%MainScreen")

var _side_menu_group := ButtonGroup.new()

## [b]PRIVATE[/b] used for unique classes to easily access them with `ClassName.get_singleton()` from any other script.
static var _singleton: Editor


## Check if a plugin is enabled using it's name.
func is_plugin_enabled(plugin_name: String) -> bool:
	if not _plugin_list.keys().has(plugin_name):
		return false
	if _plugin_list[plugin_name].is_internal():
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


## [b]PRIVATE[/b] [signal Actions.action_pressed] is connected to this function.
func _on_action(action_name: String):
	print_verbose(action_name)
	if action_name.begins_with("ED_SCREEN_"):
		var screen_idx = int(action_name)
		if screen_idx <= _side_menu.get_child_count():
			var screen_button = _side_menu.get_child(screen_idx - 1)
			if not screen_button.button_pressed:
				screen_button.button_pressed = true
				screen_button.emit_signal("toggled", true)
	if action_name == "ED_QUIT":
		_request_quit()


## [b]PRIVATE[/b] Load all plugins by calling their [method Plugin.load_plugin] method if they are enabled.
func _load_plugins() -> void:
	var files = DirAccess.get_files_at("res://packed_plugins")
	for file in files:
		if file.get_extension() != "pixel_plugin":
			continue
		ProjectSettings.load_resource_pack("res://packed_plugins/" + file)
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
				_plugin_list[plugin] = plugin_script
		for plugin in _plugin_list.values():
			if plugin.is_internal():
				plugin.load_plugin()
		for plugin_name in _plugin_list:
			var plugin = _plugin_list[plugin_name]
			if plugin.is_internal():
				continue
			if enabled_plugins.has(plugin_name):
				plugin.load_plugin()
		var to_remove := PackedInt32Array([])
		for i in enabled_plugins.size():
			if not _plugin_list.keys().has(enabled_plugins[i]):
				to_remove.append(i)
		var removed := 0
		for i in to_remove:
			enabled_plugins.remove_at(i - removed)
			removed += 1
		Settings.get_singleton().set_editor_value("editor", "enabled_plugins", enabled_plugins)
	Settings.get_singleton().set_editor_value("editor", "loaded_plugins", _plugin_list.keys())


## [b]PRIVATE[/b] Unload all plugins by calling their [method Plugin.unload_plugin] method if they are enabled.
func _unload_plugins() -> void:
	var enabled_plugins = Settings.get_singleton().get_editor_value("editor", "enabled_plugins", [])
	for plugin_name in _plugin_list.keys():
		var plugin = _plugin_list[plugin_name]
		if plugin.is_internal() || enabled_plugins.has(plugin_name):
			plugin.unload_plugin()


# [b]PRIVATE[/b] Sets a plugin enabled or disabled.
func _set_plugin_enabled(plugin_name: String, enabled: bool) -> void:
	if not _plugin_list.keys().has(plugin_name):
		return
	var enabled_plugins = Settings.get_singleton().get_editor_value("editor", "enabled_plugins", [])
	var plugin: Plugin = _plugin_list[plugin_name]
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


func _request_quit():
	var enabled_plugins = Settings.get_singleton().get_editor_value("editor", "enabled_plugins", [])
	for plugin_name in enabled_plugins:
		if not _plugin_list[plugin_name].can_exit():
			return
	get_tree().quit()


## Returns the current class unique instance. [br]
## Don't use this method for classes that will be instantiated more than once.
static func get_singleton() -> Editor:
	return _singleton


# FIXME: Minimum size should update when plugins enabled or disabled.
func _ready() -> void:
	Root.get_singleton().min_size = get_minimum_size()


func _enter_tree() -> void:
	_load_plugins()


func _exit_tree() -> void:
	_unload_plugins()
	for plugin in _plugin_list.values():
		plugin.free()


func _init():
	print_verbose("Editor _init()")
	name = "Editor"
	set_margin_all(2)
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	# Get or create projects directory.
	var user_dir := DirAccess.open(OS.get_user_data_dir())
	if user_dir:
		if not user_dir.dir_exists("plugins"):
			user_dir.make_dir("plugins")
		_plugins_dir = DirAccess.open(OS.get_user_data_dir() + "/plugins")
	# Actions.
	var actions := Actions.get_singleton()
	actions.add_action("ED_SAVE", KEY_MASK_CTRL | KEY_S)
	actions.add_action("ED_SAVE_AS", KEY_MASK_CTRL | KEY_MASK_SHIFT | KEY_S)
	actions.add_action("ED_OPEN", KEY_MASK_CTRL | KEY_O)
	actions.add_action("ED_QUIT", KEY_MASK_CTRL | KEY_Q)
	var keys = [KEY_1, KEY_2, KEY_3, KEY_4, KEY_5, KEY_6, KEY_7, KEY_8, KEY_9]
	for i in range(9):
		actions.add_action("ED_SCREEN_%s" % (i + 1), KEY_MASK_CTRL | keys[i])
	actions.action_pressed.connect(_on_action)
	# Final pass.
	_singleton = self
	add_child(_scene)
	# Used to push back internal nodes to the right in main menu.
	var main_menu_separator := Control.new()
	main_menu_separator.size_flags_horizontal = Control.SIZE_EXPAND | Control.SIZE_SHRINK_END
	_main_menu.add_child(main_menu_separator, false, Node.INTERNAL_MODE_BACK)
	# Used to push back internal nodes to the bottom in side menu.
	var side_menu_separator := Control.new()
	side_menu_separator.size_flags_vertical = Control.SIZE_EXPAND | Control.SIZE_SHRINK_END
	_side_menu.add_child(side_menu_separator, false, Node.INTERNAL_MODE_BACK)
