@tool
class_name ColorButton
extends PanelContainer

signal color_changed(col: Color)

@export var color: Color:
	set(value):
		if value != color:
			color = value
			queue_redraw()

@export var disable_alpha: bool:
	set(value):
		if value != disable_alpha:
			disable_alpha = value
			color.a = 1.0
			notify_property_list_changed()
			queue_redraw()

static var checker_style: CheckerStyleBox
static var focus_style: StyleBoxFlat


func set_color(col: Color) -> void:
	if col == color:
		return
	color = col
	color_changed.emit(color)


func _gui_input(ev: InputEvent) -> void:
	var mb: InputEventMouseButton = ev as InputEventMouseButton
	if (mb and mb.button_index == MOUSE_BUTTON_LEFT and mb.is_pressed()) or ev.is_action_pressed("ui_accept"):
		var picker_window := ColorPickerWindow.get_singleton()
		var pos = get_screen_position()
		pos.y += size.y
		picker_window.position = pos
		picker_window.picker.color = color
		picker_window.pop(set_color, not disable_alpha, true, color)


func _draw() -> void:
	var begin = Vector2(checker_style.get_margin(SIDE_LEFT), checker_style.get_margin(SIDE_TOP))
	var end = Vector2(checker_style.get_margin(SIDE_RIGHT), checker_style.get_margin(SIDE_BOTTOM))
	draw_rect(Rect2(begin, size - begin - end), color, true)
	if has_focus():
		draw_style_box(focus_style, Rect2(Vector2.ZERO, size))


func _validate_property(property: Dictionary) -> void:
	if property["name"] == "color":
		if disable_alpha:
			property["hint"] = PROPERTY_HINT_COLOR_NO_ALPHA
		else:
			property["hint"] = PROPERTY_HINT_NONE


func _init() -> void:
	if not checker_style:
		checker_style = CheckerStyleBox.new()
	add_theme_stylebox_override("panel", checker_style)
	focus_mode = Control.FOCUS_ALL
	custom_minimum_size = Vector2(16, 16)
