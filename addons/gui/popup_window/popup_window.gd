@tool
@icon("./icon.png")
class_name PopupWindow
extends Window

@export var visible_in_editor := false


func _init():
    wrap_controls = true
    exclusive = true
    initial_position = Window.WINDOW_INITIAL_POSITION_CENTER_SCREEN_WITH_KEYBOARD_FOCUS
    close_requested.connect(_on_close_requested)
    if Engine.is_editor_hint():
        visible = visible_in_editor
    else:
        visible = false


func _on_close_requested():
    hide()


func _input(ev: InputEvent):
    if not visible:
        return
    if ev.is_action_pressed("ui_cancel"):
        hide()
        get_viewport().set_input_as_handled()
