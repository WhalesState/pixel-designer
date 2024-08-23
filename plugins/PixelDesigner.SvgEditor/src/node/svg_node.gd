@tool
class_name SvgNode
extends Node

@export var visible := true:
	set(value):
		if value != visible:
			visible = value
			update()

@export var mask_id := "":
	set(value):
		if value != mask_id:
			mask_id = value
			update()

func get_svg_string() -> String:
	return ""


func update():
	if not is_inside_tree():
		return
	var parent = get_parent()
	if not parent:
		return
	while parent:
		if parent is SvgNode:
			parent = parent.get_parent()
			continue
		elif parent is SvgTextureRect:
			parent.redraw()
		break


func color_to_html(color: Color) -> String:
	var c := color.to_html(false)
	if c[0] == c[1] and c[2] == c[3] and c[4] == c[5]:
		c = c[0] + c[2] + c[4]
	return "#" + c


func _notification(what: int) -> void:
	if what == NOTIFICATION_CHILD_ORDER_CHANGED:
		update()


func _get_configuration_warnings() -> PackedStringArray:
	if is_inside_tree():
		var parent = get_parent()
		if (parent as SvgTextureRect) or (parent as SvgNode):
			return []
	return ["Parent node should inherit from SvgTextureRect or SvgNode"]
