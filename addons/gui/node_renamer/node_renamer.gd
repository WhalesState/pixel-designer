extends LineEdit
class_name NodeRenamer

signal node_renamed(new_name: String)

var node: Node


func _init(target_node: Node):
	node = target_node
	name = "NodeRenamer"
	text = node.name
	caret_blink = true
	caret_blink_interval = 0.5
	text_submitted.connect(_on_text_submitted)
	focus_exited.connect(_on_text_submitted.bind(""))
	visibility_changed.connect(_on_visibility_changed)


func _ready():
	grab_focus_edit(true)


func _on_visibility_changed():
	if visible:
		return
	node.grab_focus()
	queue_free()


func _gui_input(ev: InputEvent):
	if not ev.is_action_pressed("ui_cancel"):
		return
	hide()


func _on_text_submitted(new_text: String):
	hide()
	if new_text.is_empty():
		return
	node.name = new_text
	emit_signal("node_renamed", node.name)
