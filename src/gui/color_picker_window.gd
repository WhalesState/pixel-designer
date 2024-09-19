@tool
class_name ColorPickerWindow
extends Window

var picker := ColorPicker.new()

var callable: Callable:
	set(value):
		if value != callable:
			if callable.is_valid():
				picker.color_changed.disconnect(callable)
			callable = value
			if callable.is_valid():
				picker.color_changed.connect(callable)

static var _singleton: ColorPickerWindow


func pop(_callable: Callable, edit_alpha := true, display_old_color := false, old_color := Color.BLACK):
	size = Vector2i.ZERO
	picker.set_display_old_color(display_old_color)
	picker.set_old_color(old_color)
	picker.edit_alpha = edit_alpha
	callable = _callable
	popup()


static func get_singleton() -> ColorPickerWindow:
	return _singleton


func _shortcut_input(ev: InputEvent) -> void:
	if ev.is_action_pressed("ui_cancel"):
		hide()


func _init() -> void:
	print_verbose("ColorPickerWindow _init()")
	name = "ColorPickerWindow"
	title = "Color Picker"
	visible = false
	transient_to_focused = true
	always_on_top = true
	wrap_controls = true
	popup_window = true
	borderless = true
	picker.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(picker)
	close_requested.connect(hide)
	_singleton = self
