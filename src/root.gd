class_name Root
extends Window

## [b]PRIVATE[/b] used for unique classes to easily access them with `ClassName.get_singleton()` from any other script.
static var _singleton: Root


## Returns the current class unique instance. [br]
## Don't use this method for classes that will be instantiated more than once.
static func get_singleton() -> Root:
	return _singleton


func _ready():
	if OS.has_feature("editor"):
		always_on_top = true


func _enter_tree() -> void:
	pass


func _exit_tree() -> void:
	pass


func _shortcut_input(ev: InputEvent) -> void:
	var k = ev as InputEventKey
	if not k or k.is_echo():
		return
	if k.keycode in [KEY_ALT, KEY_CTRL, KEY_SHIFT, KEY_META]:
		return
	if k.is_pressed():
		var key = k.keycode
		if k.is_command_or_control_pressed():
			key |= KEY_MASK_CTRL
		if k.shift_pressed:
			key |= KEY_MASK_SHIFT
		if k.alt_pressed:
			key |= KEY_MASK_ALT
		Actions.get_singleton()._run_action(key)


func _init():
	print_verbose("Root _init()")
	theme = EditorTheme.new()
	var editor = Editor.new()
	add_child(editor)
	close_requested.connect(editor._request_quit)
	add_child(Settings.get_singleton().window)
	# Final pass
	_singleton = self
