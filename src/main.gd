class_name Main
extends SceneTree

## Stores the project version.
var version := ProjectSettings.get_setting("application/config/version", "0.1") as String

## `PRIVATE` A class that can be used to queue calls a function many times and it will be excuted only once or as many times as needed.
var _message_queue := MessageQueue.new()
## `PRIVATE` A class that contains all the project actions.
var _actions := Actions.new()

## `PRIVATE` Stores the log messages when exiting in the user date log file.
var _log_queue := PackedStringArray([])

## `PRIVATE` used for unique classes to easily access them with `ClassName.get_singleton()` from any other script.
static var _singleton: Main


## Returns the current class unique instance. [br]
## Don't use this method for classes that will be instantiated more than once.
static func get_singleton() -> Main:
	return _singleton


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
	root.set_script(preload("res://src/root.gd"))
	# Final pass.
	_singleton = self
