@tool
@icon("./icon.png")
class_name PopupWindow
extends Window

@export var visible_in_editor := false


func _ready():
    wrap_controls = true
    close_requested.connect(_on_close_requested)
    if Engine.is_editor_hint() && get_tree().edited_scene_root:
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
