@tool
@icon("./icon.png")
class_name PopupWindow
extends Window

@export var visible_in_editor := false


func _ready():
	wrap_controls = true
	close_requested.connect(_on_close_requested)
	if Engine.is_editor_hint():
		visible = visible_in_editor
	else:
		visible = false
#	get_viewport().size_changed.connect(_on_vp_resized)


func _on_close_requested():
	hide()


func _input(ev: InputEvent):
	if not visible:
		return
	if not ev.is_action_pressed("ui_cancel"):
		return
	hide()


#func _on_vp_resized():
#	var root
#	if not Engine.is_editor_hint():
#		root = get_tree().get_root()
#	if root:
#		position = (root.get_viewport().size - size) / 2
