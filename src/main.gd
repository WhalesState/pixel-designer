class_name Main
extends SceneTree

## `PRIVATE` A class that can be used to queue calls a function many times and it will be excuted only once or as many times as needed.
var _message_queue := MessageQueue.new()

## `PRIVATE` A class that contains all the project actions.
var _actions := Actions.new()

## `PRIVATE` Stores the log messages when exiting in the user date log file.
var _log_queue := PackedStringArray([])

## `PRIVATE` used for unique classes to easily access them with `ClassName.get_singleton()` from any other script.
static var _singleton: Main


## Use `Main.get_version()` to get the current version.
static func get_version() -> String:
	return ProjectSettings.get_setting("application/config/version", "0.1")


## Returns the current class unique instance. [br]
## Don't use this method for classes that will be instantiated more than once.
static func get_singleton() -> Main:
	return _singleton


## Returns a list of all files in a directory.
static func _get_dir_files(path: String) -> Array:
	var files := []
	var dir = DirAccess.open(path)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "": 
			if dir.current_is_dir():
				files.append_array(_get_dir_files(dir.get_current_dir() + "/" + file_name))
			else:
				files.append(dir.get_current_dir() + "/" + file_name)
			file_name = dir.get_next()
		dir.list_dir_end()
	return files


## for Editor builds: Update the export presets if `res://export_presets.cfg` exists.
func _update_export_presets() -> void:
	if OS.has_feature("editor") and FileAccess.file_exists("res://export_presets.cfg"):
		var cfg = ConfigFile.new()
		cfg.load("res://export_presets.cfg")
		var presets := []
		for preset in cfg.get_sections():
			if preset.ends_with(".options"):
				continue
			presets.append(preset)
		if presets.is_empty():
			cfg.free()
			return
		# update presets
		var excluded := PackedStringArray([])
		for file in Main._get_dir_files("res://plugins"):
			if file.get_extension() in ["import", "pixel_plugin"]:
				continue
			excluded.append(file)
		for file in Main._get_dir_files("res://theme/icons"):
			if file.get_extension() in ["svg"]:
				excluded.append(file)
		var include_filter = "*.pixel_icon, *.pixel_plugin"
		for preset in presets:
			cfg.set_value(preset, "export_filter", "exclude")
			if not excluded.is_empty():
				print(preset)
				cfg.set_value(preset, "export_files", excluded)
			cfg.set_value(preset, "include_filter", include_filter)
		cfg.save("res://export_presets.cfg")


func _finalize() -> void:
	var log_file = FileAccess.open(OS.get_user_data_dir() + "/pixel_designer.log", FileAccess.WRITE)
	# NOTE: When exiting the app, the builtin message queue will flush! no more output to console.
	if log_file:
		for message in _message_queue._messages:
			_log_queue.append("MessageQueue: Method: %s was not called before exiting!" % message.get_method())
		for log_message in _log_queue:
			log_file.store_line(log_message)
		log_file.close()
	_message_queue.free()
	_actions.free()


func _process(_delta):
	if _message_queue._messages.size() > 0:
		for callable in _message_queue._messages:
			if callable.is_valid():
				callable.call()
		_message_queue._messages.clear()


func _init():
	print_verbose("Main _init()")
	_actions.action_map_changed.connect(func():
		_message_queue.queue_call(_actions._store_actions)
	)
	# Final pass.
	_update_export_presets()
	_singleton = self
	root.set_script(preload("res://src/root.gd"))
