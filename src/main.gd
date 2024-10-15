class_name Main
extends SceneTree

## [b]PRIVATE[/b] A class that can be used to queue calls a function many times and it will be excuted only once or as many times as needed.
var _message_queue := MessageQueue.new()

## [b]PRIVATE[/b] A class that contains all the editor actions.
var _actions := Actions.new()

## [b]PRIVATE[/b] A class that manages the editor settings.
var _settings := Settings.new()

## [b]PRIVATE[/b] Stores the log messages when exiting in the user date log file.
var _log_queue := PackedStringArray([])

## [b]PRIVATE[/b] used for unique classes to easily access them with `ClassName.get_singleton()` from any other script.
static var _singleton: Main:
	set(value):
		if _singleton:
			return
		_singleton = value


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
	if not FileAccess.file_exists("res://export_presets.cfg"):
		return
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
	var include_filter = "*.pixel_icon,*.pixel_plugin"
	var exclude_filter = "plugins/*,theme/icons/*,playground/*,bin/*,export_templates/*,*.md"
	for preset in presets:
		cfg.set_value(preset, "include_filter", include_filter)
		cfg.set_value(preset, "exclude_filter", exclude_filter)
	cfg.save("res://export_presets.cfg")


## [b]PRIVATE[/b] Packs all plugins into a Pck file and saves it in user data plugins folder.
func _pack_plugins() -> void:
	var plugins_dir = DirAccess.open("res://plugins")
	if not plugins_dir:
		print_verbose("Error: Failed to pack plugins. res://plugins/ : %s" % plugins_dir)
		return
	## Pack all plugins.
	for plugin in plugins_dir.get_directories():
		var plugin_path = "res://plugins/" + plugin
		var files = Main._get_dir_files(plugin_path)
		if files.size() > 0:
			var pck := PCKPacker.new()
			pck.pck_start("res://packed_plugins/" + plugin + ".pixel_plugin")
			for file in files:
				pck.add_file(file.replace("res://plugins/", "res://loaded_plugins/") , file)
			pck.flush(OS.is_stdout_verbose())
	## Delete all orphan plugins.
	var packed_plugins_dir = DirAccess.open("res://packed_plugins")
	if not packed_plugins_dir:
		print_verbose("Error: Failed to pack plugins. res://packed_plugins/ : %s" % packed_plugins_dir)
		return
	var packed_plugins = DirAccess.get_files_at("res://packed_plugins")
	for plugin_file in packed_plugins:
		if not plugin_file.get_extension() == "pixel_plugin":
			continue
		if not plugins_dir.dir_exists(plugin_file.get_basename()):
			packed_plugins_dir.remove(plugin_file)


## [b]PRIVATE[/b] Generates the theme icons.
func _generate_theme_icons():
	# Generate pixel icons.
	var icons_dir := DirAccess.open("res://theme/icons")
	if not icons_dir:
		print_verbose("Error: Failed to generate theme icons. res://theme/icons/ : %s" % icons_dir)
		return
	for file in icons_dir.get_files():
		if file.get_extension() != "svg":
			continue
		var svg_file := FileAccess.open("res://theme/icons/" + file, FileAccess.READ)
		if not svg_file:
			continue
		var svg = svg_file.get_as_text()
		svg_file.close()
		var pixel_icon := FileAccess.open("res://theme/generated_icons/" + file.get_basename() + ".pixel_icon", FileAccess.WRITE)
		pixel_icon.store_string(svg)
		pixel_icon.close()
	# Delete all orphan pixel icons.
	var generated_icons_dir := DirAccess.open("res://theme/generated_icons")
	if not generated_icons_dir:
		print_verbose("Error: Failed to generate theme icons. res://theme/generated_icons/ : %s" % generated_icons_dir)
		return
	for file in generated_icons_dir.get_files():
		if file.get_extension() != "pixel_icon":
			continue
		if not icons_dir.file_exists(file.get_basename() + ".svg"):
			generated_icons_dir.remove(file)
			continue


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
	_settings.free()


func _process(_delta):
	if _message_queue._messages.size() > 0:
		var _messages = _message_queue._messages.duplicate()
		_message_queue._messages.clear()
		for callable in _messages:
			if callable.is_valid():
				callable.call()


func _init():
	print_verbose("Main _init()")
	_actions.action_map_changed.connect(func():
		_message_queue.queue_call(_actions._store_actions)
	)
	_settings.settings_changed.connect(func():
		_message_queue.queue_call(_settings._save_settings)
	)
	_settings.defaults_changed.connect(func():
		_message_queue.queue_call(_settings._save_defaults)
	)
	# Final pass.
	_singleton = self
	if OS.has_feature("editor"):
		_update_export_presets()
		_pack_plugins()
		_generate_theme_icons()
	root.set_script(preload("res://src/root.gd"))
