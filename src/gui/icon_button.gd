@tool
class_name IconButton
extends Button

@export var normal_icon: Texture:
	set(value):
		normal_icon = value
		_update_icon(button_pressed)

@export var pressed_icon: Texture:
	set(value):
		pressed_icon = value
		_update_icon(button_pressed)


func _init():
	toggle_mode = true
	toggled.connect(_update_icon)


func _update_icon(_is_pressed: bool):
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
