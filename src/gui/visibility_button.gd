@tool
class_name VisibilityButton
extends Button


@export var normal_icon: Texture:
	set(value):
		normal_icon = value
		_update_icon(button_pressed)

@export var pressed_icon: Texture:
	set(value):
		pressed_icon = value
		_update_icon(button_pressed)

@export var node: CanvasItem:
	set(value):
		node = value
		if node:
			button_pressed = node.visible

func _init():
	toggle_mode = true
	if not toggled.is_connected(_update_icon):
		toggled.connect(_update_icon)


func _update_icon(_is_pressed: bool):
	if node:
		node.visible = _is_pressed
	if _is_pressed:
		if pressed_icon:
			icon = pressed_icon
		elif normal_icon:
			icon = normal_icon
		else:
			icon = null
	else:
		if normal_icon:
			icon = normal_icon
		else:
			icon = null
