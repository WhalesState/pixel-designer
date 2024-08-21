class_name Main
extends SceneTree

var version := ProjectSettings.get_setting("application/config/version", "0.1") as String

var message_queue := MessageQueue.new()
var actions := Actions.new()

var root_script: Script = preload("res://src/root.gd")

var log_queue := PackedStringArray([])

static var singleton: Main


static func get_singleton() -> Main:
	return singleton


func _finalize() -> void:
	var log_file = FileAccess.open(OS.get_user_data_dir() + "/pixel_designer.log", FileAccess.WRITE)
	# NOTE: When exiting the app, the builtin message queue will flush! no more output to console.
	if log_file:
		for message in message_queue._messages:
			log_queue.append("MessageQueue: Method: %s was not called before exiting!" % message.get_method())
		for log_message in log_queue:
			log_file.store_line(log_message)
		log_file.close()
	message_queue.free()
	actions.free()


func _process(_delta):
	if message_queue._messages.size() > 0:
		for callable in message_queue._messages:
			if callable.is_valid():
				callable.call()
		message_queue._messages.clear()


func _init():
	print_verbose("Main _init()")
	actions.action_map_changed.connect(func():
		message_queue.queue_call(actions._store_actions)
	)
	root.set_script(root_script)
	# Final pass.
	singleton = self
