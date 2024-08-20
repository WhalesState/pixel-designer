class_name Root
extends Window

static var singleton: Root


static func get_singleton() -> Root:
	return singleton


func _ready():
	#Settings.get_singleton().popup_centered()
	pass


func _init():
	print_debug("Root _init()")
	add_child(Settings.new())
	theme = EditorTheme.new()
	add_child(Editor.new())
	# Final pass
	singleton = self


func _input(event: InputEvent):
	var k = event as InputEventKey
	if not k or k.is_echo():
		return

	if k.keycode == KEY_M and k.is_pressed():
		var es = EditorTheme.get_singleton()
		es.current_font = es.fonts.keys()[wrapi(es.fonts.keys().find(es.current_font) + 1, 0, es.fonts.size())]
		var ed = Editor.get_singleton()
		ed._set_plugin_enabled("PixelDesigner.UpdateSpinner", not ed.is_plugin_enabled("PixelDesigner.UpdateSpinner"))
		ed._set_plugin_enabled("PixelDesigner.UpdateSpinner2", not ed.is_plugin_enabled("PixelDesigner.UpdateSpinner2"))
		
