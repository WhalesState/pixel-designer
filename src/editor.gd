class_name Editor
extends PanelContainer

enum {
	MENU_SETTINGS = 128,
	MENU_EXIT,
}

## [b]PRIVATE[/b] The plugins directory inside user data directory.
var _plugins_dir: DirAccess

## [b]PRIVATE[/b] A list of all project plugins.
var _plugin_list := {}

var _main_vbox := VBoxContainer.new()
var _main_menu := HBoxContainer.new()
var _main_hbox := HBoxContainer.new()
var _side_menu_scroll := ScrollContainer.new()
var _side_menu := VBoxContainer.new()
var _main_screen := MarginContainer.new()
var _editor_menu := MenuButton.new()

@warning_ignore("unused_private_class_variable")
var _side_menu_group := ButtonGroup.new()

## [b]PRIVATE[/b] used for unique classes to easily access them with `ClassName.get_singleton()` from any other script.
static var _singleton: Editor:
	set(value):
		if _singleton:
			return
		_singleton = value


## Check if a plugin is enabled using it's name.
func is_plugin_enabled(plugin_name: String) -> bool:
	if not _plugin_list.keys().has(plugin_name):
		return false
	if _plugin_list[plugin_name].is_internal():
		return true
	return Settings.get_singleton().get_value("editor", "enabled_plugins", []).has(plugin_name)


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
		var enabled_plugins: Array = Settings.get_singleton().get_value("editor", "enabled_plugins", ["UpdateSpinner", "ThemeEditor", "Test"])
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
		Settings.get_singleton().set_value("editor", "enabled_plugins", enabled_plugins)
		PluginManager.get_singleton()._update_plugins()


## [b]PRIVATE[/b] Unload all plugins by calling their [method Plugin.unload_plugin] method if they are enabled.
func _unload_plugins() -> void:
	var enabled_plugins = Settings.get_singleton().get_value("editor", "enabled_plugins", [])
	for plugin_name in _plugin_list.keys():
		var plugin = _plugin_list[plugin_name]
		if plugin.is_internal() || enabled_plugins.has(plugin_name):
			plugin.unload_plugin()


# [b]PRIVATE[/b] Sets a plugin enabled or disabled.
func _set_plugin_enabled(plugin_name: String, enabled: bool) -> void:
	if not _plugin_list.keys().has(plugin_name):
		return
	var enabled_plugins = Settings.get_singleton().get_value("editor", "enabled_plugins", [])
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
	Settings.get_singleton().set_value("editor", "enabled_plugins", enabled_plugins)


func _request_quit():
	var enabled_plugins = Settings.get_singleton().get_value("editor", "enabled_plugins", [])
	for plugin_name in enabled_plugins:
		if not _plugin_list[plugin_name].can_exit():
			return
	get_tree().quit()


## Returns the current class unique instance. [br]
## Don't use this method for classes that will be instantiated more than once.
static func get_singleton() -> Editor:
	return _singleton


func _update_editor_menu():
	var actions := Actions.get_singleton()._actions
	_editor_menu.text = tr("Editor")
	var popup := _editor_menu.get_popup()
	popup.clear()
	popup.add_item(tr("Settings"), MENU_SETTINGS, actions["ED_SETTINGS"])
	popup.add_separator()
	popup.add_item(tr("Exit"), MENU_EXIT, actions["ED_EXIT"])


func _on_editor_menu_id_pressed(id: int):
	match id:
		MENU_SETTINGS:
			Settings.get_singleton().window.popup_centered()
		MENU_EXIT:
			_request_quit()


func _notification(what: int) -> void:
	match what:
		NOTIFICATION_ENTER_TREE:
			_load_plugins()
			_update_editor_menu()
		NOTIFICATION_EXIT_TREE:
			_unload_plugins()
			for plugin in _plugin_list.values():
				plugin.free()
		NOTIFICATION_TRANSLATION_CHANGED:
			_update_editor_menu()
			if _plugin_list.is_empty():
				return
			var enabled_plugins = Settings.get_singleton().get_value("editor", "enabled_plugins", [])
			for plugin_name in enabled_plugins:
				_plugin_list[plugin_name].translation_changed.emit()


# FIXME: Minimum size should update when a plugin is enabled or disabled.
func _ready() -> void:
	Actions.get_singleton().action_map_changed.connect(_update_editor_menu)


func _init():
	print_verbose("Editor _init()")
	name = "Editor"
	# Get or create projects directory.
	var user_dir := DirAccess.open(OS.get_user_data_dir())
	if user_dir:
		if not user_dir.dir_exists("plugins"):
			user_dir.make_dir("plugins")
		_plugins_dir = DirAccess.open(OS.get_user_data_dir() + "/plugins")
	# Actions.
	var actions := Actions.get_singleton()
	actions.add_action("ED_SETTINGS", KEY_MASK_CTRL | KEY_QUOTELEFT)
	actions.add_action("ED_EXIT", KEY_MASK_CTRL | KEY_Q)
	var keys = [KEY_1, KEY_2, KEY_3, KEY_4, KEY_5, KEY_6, KEY_7, KEY_8, KEY_9]
	for i in range(9):
		actions.add_action("ED_SCREEN_%s" % (i + 1), KEY_MASK_CTRL | keys[i])
	actions.action_pressed.connect(_on_action)
	# Final pass.
	_singleton = self
	# Editor UI.
	theme_type_variation = "FlatPanel"
	set_anchors_and_offsets_preset(PRESET_FULL_RECT)
	_main_vbox.name = "MainVBox"
	add_child(_main_vbox)
	_main_menu.name = "MainMenu"
	_main_vbox.add_child(_main_menu)
	_main_hbox.name = "MainHBox"
	_main_hbox.size_flags_vertical = SIZE_EXPAND_FILL
	_main_vbox.add_child(_main_hbox)
	_side_menu_scroll.name = "SideMenuScroll"
	_side_menu_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	_side_menu_scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_SHOW_NEVER
	_main_hbox.add_child(_side_menu_scroll)
	_side_menu.name = "SideMenu"
	_side_menu.size_flags_vertical = SIZE_EXPAND_FILL
	_side_menu_scroll.add_child(_side_menu)
	_main_screen.name = "MainScreen"
	_main_screen.size_flags_horizontal = SIZE_EXPAND_FILL
	_main_hbox.add_child(_main_screen)
	# Used to push back internal nodes to the right in main menu.
	var main_menu_separator := Control.new()
	main_menu_separator.size_flags_horizontal = Control.SIZE_EXPAND | Control.SIZE_SHRINK_END
	_main_menu.add_child(main_menu_separator, false, Node.INTERNAL_MODE_BACK)
	# Used to push back internal nodes to the bottom in side menu.
	var side_menu_separator := Control.new()
	side_menu_separator.size_flags_vertical = Control.SIZE_EXPAND | Control.SIZE_SHRINK_END
	_side_menu.add_child(side_menu_separator, false, Node.INTERNAL_MODE_BACK)
	# Editor Menu
	_editor_menu.focus_mode = FOCUS_ALL
	_editor_menu.get_popup().id_pressed.connect(_on_editor_menu_id_pressed)
	_main_menu.add_child(_editor_menu, false)
