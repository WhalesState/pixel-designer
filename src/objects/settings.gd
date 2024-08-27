class_name Settings
extends Object

signal settings_changed

## [b]PRIVATE[/b] contains all the editor settings. [br]
## use get_editor_value() and set_editor_value() to access them.
var _editor_settings := ConfigFile.new()

## [b]PRIVATE[/b] used for unique classes to easily access them with `ClassName.get_singleton()` from any other script.
static var _singleton: Settings


## Sets an editor settings value and saves the editor settings file on the next frame.
func set_editor_value(section: String, key: String, value: Variant) -> void:
	_editor_settings.set_value(section, key, value)
	settings_changed.emit()


## Returns a value from the editor settings. [br]
## If the value doesn't exists, it will call `set_editor_value(section, key, default)` and will return the default value.
func get_editor_value(section: String, key: String, default: Variant) -> Variant:
	if not _editor_settings.has_section_key(section, key):
		set_editor_value(section, key, default)
		return default
	else:
		return _editor_settings.get_value(section, key, default)


## [b]PRIVATE[/b] don't use directly unless you want to save the editor settings file on the same frame.
func _save_editor_settings():
	_editor_settings.save(OS.get_user_data_dir() + "/editor_settings.cfg")


## Returns the current class unique instance. [br]
## Don't use this method for classes that will be instantiated more than once.
static func get_singleton() -> Settings:
	return _singleton


func _init():
	print_verbose("Settings _init()")
	if FileAccess.file_exists(OS.get_user_data_dir() + "/editor_settings.cfg"):
		_editor_settings.load(OS.get_user_data_dir() + "/editor_settings.cfg")
	else:
		settings_changed.emit()
	# Final pass.
	_singleton = self
