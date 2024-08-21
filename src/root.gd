class_name Root
extends Window

static var singleton: Root


static func get_singleton() -> Root:
	return singleton


func _ready():
	#Settings.get_singleton().popup_centered()
	pass


func _init():
	print_verbose("Root _init()")
	add_child(Settings.new())
	theme = EditorTheme.new()
	add_child(Editor.new())
	# Final pass
	singleton = self


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


#func _input(event: InputEvent):
	#var k = event as InputEventKey
	#if not k or k.is_echo():
		#return
	#if k.keycode == KEY_M and k.is_pressed():
		#var es = EditorTheme.get_singleton()
		#es.current_font = es.fonts.keys()[wrapi(es.fonts.keys().find(es.current_font) + 1, 0, es.fonts.size())]
		#var ed = Editor.get_singleton()
		#ed._set_plugin_enabled("PixelDesigner.UpdateSpinner", not ed.is_plugin_enabled("PixelDesigner.UpdateSpinner"))
		#ed._set_plugin_enabled("PixelDesigner.UpdateSpinner2", not ed.is_plugin_enabled("PixelDesigner.UpdateSpinner2"))
		#
