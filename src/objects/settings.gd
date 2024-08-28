class_name Settings
extends Object

## Emits when settings are changed.
signal settings_changed

## Emits when default settings are changed.
signal defaults_changed

var window = Window.new()

## [b]PRIVATE[/b] contains all the editor settings. [br]
## use [method get_value] and [method set_value] to access them.
var _editor_settings := ConfigFile.new()
var _editor_settings_defaults := ConfigFile.new()

## [b]PRIVATE[/b] used for unique classes to easily access them with `ClassName.get_singleton()` from any other script.
static var _singleton: Settings


## Sets an editor settings value and saves the editor settings file on the next frame.
func set_value(section: String, key: String, value: Variant, save_default := true) -> void:
	_editor_settings.set_value(section, key, value)
	if save_default:
		if _editor_settings_defaults.has_section_key(section, key):
			print_verbose("WARNING: default value for %s:%s has been overwritten" % [section, key])
		_editor_settings_defaults.set_value(section, key, value)
		defaults_changed.emit()
	settings_changed.emit()


## Returns a value from the editor settings config file. [br]
## If the value doesn't exists, it will call `set_value(section, key, default)` and will return the default value.
func get_value(section: String, key: String, default: Variant, save_default := true) -> Variant:
	if not _editor_settings.has_section_key(section, key):
		set_value(section, key, default, save_default)
		return default
	else:
		return _editor_settings.get_value(section, key, default)


## Returns true if the editor settings has a default value for the given section key.
func has_default_value(section: String, key: String) -> bool:
	return _editor_settings_defaults.has_section_key(section, key)


## [b]PRIVATE[/b] Sets the default value for the given section key.
func _set_default_value(section: String, key: String, value: Variant) -> void:
	_editor_settings_defaults.set_value(section, key, value)
	defaults_changed.emit()


## [b]PRIVATE[/b] Returns the default value for the given section key or default if the value doesn't exists.
func _get_default_value(section: String, key: String, default: Variant = null) -> Variant:
	if _editor_settings_defaults.has_section_key(section, key):
		return _editor_settings_defaults.get_value(section, key, default)
	return default


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
	window.title = "Settings"
	window.visible = false
	window.transient = true
	window.exclusive = true
	window.wrap_controls = true
	window.close_requested.connect(window.hide)
	if FileAccess.file_exists(OS.get_user_data_dir() + "/editor_settings.cfg"):
		_editor_settings.load(OS.get_user_data_dir() + "/editor_settings.cfg")
	if FileAccess.file_exists(OS.get_user_data_dir() + "/editor_settings_defaults.cfg"):
		_editor_settings_defaults.load(OS.get_user_data_dir() + "/editor_settings_defaults.cfg")
	# Final pass.
	_singleton = self
