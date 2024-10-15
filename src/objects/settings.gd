class_name Settings
extends Object

## Emits when settings are changed.
signal settings_changed

## Emits when default settings are changed.
signal defaults_changed

## The Settings window.
var window := Window.new()

var _side_menu := VBoxContainer.new()
var _main_screen := MarginContainer.new()

@warning_ignore("unused_private_class_variable")
var _side_menu_group := ButtonGroup.new()

## [b]PRIVATE[/b] contains all the editor settings. [br]
## Use [method get_value] and [method set_value] to access them.
var _editor_settings := ConfigFile.new()

## [b]PRIVATE[/b] contains all editor settings defaults. [br]
## Use [method get_default_value] and [method set_default_value]
var _editor_settings_defaults := ConfigFile.new()

## [b]PRIVATE[/b] used for unique classes to easily access them with `ClassName.get_singleton()` from any other script.
static var _singleton: Settings:
	set(value):
		if _singleton:
			return
		_singleton = value


## Sets an editor settings value and saves the editor settings file on the next frame. [br]
## If [param save_default] is true, a default value will be saved.
func set_value(section: String, key: String, value: Variant, save_default := false) -> void:
	_editor_settings.set_value(section, key, value)
	if save_default:
		if _editor_settings_defaults.has_section_key(section, key):
			print_verbose("Error: default value for %s:%s already exists." % [section, key])
			return
		_editor_settings_defaults.set_value(section, key, value)
		defaults_changed.emit()
	settings_changed.emit()


## Returns a value from the editor settings config file. [br]
## If the value doesn't exists, it will call `set_value(section, key, default)` and will return the default value.
func get_value(section: String, key: String, default: Variant, save_default := false) -> Variant:
	if not _editor_settings.has_section_key(section, key):
		set_value(section, key, default, save_default)
		return default
	else:
		return _editor_settings.get_value(section, key, default)


## Returns true if the editor settings has a default value for the given section key.
func has_default_value(section: String, key: String) -> bool:
	return _editor_settings_defaults.has_section_key(section, key)


## Returns the default value for the given section key or default if the value doesn't exists.
func get_default_value(section: String, key: String, default: Variant = null) -> Variant:
	if _editor_settings_defaults.has_section_key(section, key):
		return _editor_settings_defaults.get_value(section, key, default)
	return default


## [b]PRIVATE[/b] Sets the default value for the given section key, and saves the editor settings defaults file. [br]
## Example: [code]get_value("my_section", "my_key", "my_default")[/code] will create a new value and a new 
## default value for the given section key and will return [code]"my_default"[/code] if the value doesn't exists. [br]
## Optionally you can set `save_default` to `true` to save the default value if it doesn't exists, check [method set_value] and [method get_value].
func _set_default_value(section: String, key: String, value: Variant) -> void:
	_editor_settings_defaults.set_value(section, key, value)
	defaults_changed.emit()


## [b]PRIVATE[/b] don't use directly unless you want to save the settings file on the same frame.
func _save_settings():
	_editor_settings.save(OS.get_user_data_dir() + "/editor_settings.cfg")


## [b]PRIVATE[/b] don't use directly unless you want to save the settings defaults file on the same frame.
func _save_defaults():
	_editor_settings_defaults.save(OS.get_user_data_dir() + "/editor_settings_defaults.cfg")


## Returns the current class unique instance. [br]
## Don't use this method for classes that will be instantiated more than once.
static func get_singleton() -> Settings:
	return _singleton


func _init():
	print_verbose("Settings _init()")
	window.name = "SettingsWindow"
	window.size = Vector2i(800, 600)
	window.title = "Settings"
	window.visible = false
	window.transient = true
	window.exclusive = true
	window.wrap_controls = true
	window.close_requested.connect(window.hide)
	window.window_input.connect(func(ev: InputEvent):
		if not ev.is_action_pressed("ui_cancel"):
			return
		window.hide()
	)
	var panel = PanelContainer.new()
	panel.name = "SettingsPanel"
	panel.theme_type_variation = "FlatPanel"
	panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	window.add_child(panel)
	var split = HSplitContainer.new()
	split.name = "SettingsSplit"
	panel.add_child(split)
	var side_menu_scroll = ScrollContainer.new()
	side_menu_scroll.name = "SideMenuScroll"
	side_menu_scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_SHOW_NEVER
	side_menu_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	split.add_child(side_menu_scroll)
	_side_menu.name = "SideMenu"
	_side_menu.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_side_menu.size_flags_vertical = Control.SIZE_EXPAND_FILL
	side_menu_scroll.add_child(_side_menu)
	var main_screen_scroll = ScrollContainer.new()
	main_screen_scroll.name = "MainScreenScroll"
	main_screen_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	split.add_child(main_screen_scroll)
	_main_screen.name = "MainScreen"
	_main_screen.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_main_screen.size_flags_vertical = Control.SIZE_EXPAND_FILL
	main_screen_scroll.add_child(_main_screen)
	if FileAccess.file_exists(OS.get_user_data_dir() + "/editor_settings.cfg"):
		_editor_settings.load(OS.get_user_data_dir() + "/editor_settings.cfg")
	if FileAccess.file_exists(OS.get_user_data_dir() + "/editor_settings_defaults.cfg"):
		_editor_settings_defaults.load(OS.get_user_data_dir() + "/editor_settings_defaults.cfg")
	# Final pass.
	_singleton = self
