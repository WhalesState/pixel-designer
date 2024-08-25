@tool
class_name SvgNode
extends Node

@export var svg : Svg:
	set(value):
		if value != svg:
			if svg:
				svg.changed.disconnect(update)
			svg = value
			if svg:
				svg.changed.connect(update)
			update()

@export var visible := true:
	set(value):
		if value != visible:
			visible = value
			update()


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


func get_svg_string() -> String:
	if svg:
		return svg.get_svg_string()
	return ""


func _notification(what: int) -> void:
	if what == NOTIFICATION_CHILD_ORDER_CHANGED:
		update()


func _get_configuration_warnings() -> PackedStringArray:
	if is_inside_tree():
		var parent = get_parent()
		if (parent as SvgTextureRect) or (parent as SvgNode):
			return []
	return ["Parent node should inherit from SvgTextureRect or SvgNode"]
