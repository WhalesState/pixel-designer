@tool
@icon("./icon.png")
class_name ToolButton
extends Button

@export var normal_icon: Texture2D:
    set(v):
        normal_icon = v
        if not button_pressed:
            icon = normal_icon

@export var pressed_icon: Texture2D:
    set(v):
        pressed_icon = v
        if button_pressed:
            icon = pressed_icon


func _init():
    theme_type_variation = "ToolButton"
    button_down.connect(_on_toggled.bind(true))
    button_up.connect(_on_toggled.bind(false))


func _on_toggled(is_pressed: bool):
    if normal_icon and pressed_icon:
        var is_really_pressed = button_pressed if toggle_mode else is_pressed
        icon = pressed_icon if is_really_pressed else normal_icon
