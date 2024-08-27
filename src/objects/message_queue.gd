class_name MessageQueue
extends Object

## [b]PRIVATE[/b] Stores the message queue.
var _messages := []

## [b]PRIVATE[/b] used for unique classes to easily access them with `ClassName.get_singleton()` from any other script.
static var _singleton: MessageQueue


## Calls a method on the next frame, if once is true, the method will not be added twice to the queue.
func queue_call(callable: Callable, once := true):
	if once:
		if _messages.has(callable):
			print_verbose("CALLABLE Already EXISTS: Object: %s, Method: %s" % [callable.get_object(), callable.get_method()])
			return
	_messages.push_back(callable)


## Returns the current class unique instance. [br]
## Don't use this method for classes that will be instantiated more than once.
static func get_singleton() -> MessageQueue:
	return _singleton


func _init():
	# Final pass.
	_singleton = self
