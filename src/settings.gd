class_name Settings
extends Window

var editor_settings := ConfigFile.new()
var project_settings := ConfigFile.new()

static var singleton: Settings


func set_editor_value(section: String, key: String, value: Variant) -> void:
	editor_settings.set_value(section, key, value)
	save_editor_settings()


func get_editor_value(section: String, key: String, default: Variant) -> Variant:
	if not editor_settings.has_section_key(section, key):
		set_editor_value(section, key, default)
		return default
	else:
		return editor_settings.get_value(section, key, default)


func save_editor_settings():
	MessageQueue.get_singleton().queue_call(_save_editor_settings)


func _save_editor_settings():
	editor_settings.save(OS.get_user_data_dir() + "/editor_settings.cfg")


static func get_singleton() -> Settings:
	return singleton


func _init():
	print_verbose("Settings _init()")
	name = "EditorSettingsWindow"
	title = "Editor Settings"
	exclusive = true
	transient = true
	visible = false
	if FileAccess.file_exists(OS.get_user_data_dir() + "/editor_settings.cfg"):
		editor_settings.load(OS.get_user_data_dir() + "/editor_settings.cfg")
	else:
		save_editor_settings()
	about_to_popup.connect(func():
		pass
	)
	close_requested.connect(func():
		hide()
	)
	# Final pass.
	singleton = self
