class_name Main
extends SceneTree

var version = ProjectSettings.get_setting_with_override("application/config/version")

var message_queue := MessageQueue.new()

var root_script: Script = preload("res://src/root.gd")

static var singleton: Main


static func get_singleton() -> Main:
	return singleton


func _finalize() -> void:
	message_queue.free()


func _process(_delta):
	if message_queue._messages.size() > 0:
		for callable in message_queue._messages:
			print(callable)
			if callable.is_valid():
				callable.call()
		message_queue._messages.clear()


func _init():
	print_debug("Main _init()")
	# First pass. [create editor data]
	root.set_script(root_script)
	# Final pass.
	singleton = self
