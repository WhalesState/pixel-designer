class_name MessageQueue
extends Object

var _messages := []

static var singleton: MessageQueue


func queue_call(callable: Callable, once := true):
	if once:
		if _messages.has(callable):
			print_verbose("CALLABLE Already EXISTS: Object: %s, Method: %s" % [callable.get_object(), callable.get_method()])
			return
	_messages.push_back(callable)


static func get_singleton() -> MessageQueue:
	return singleton


func _init():
	# Final pass.
	singleton = self
