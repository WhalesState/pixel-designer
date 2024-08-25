@tool
class_name SvgMask
extends SvgNode

@export var mask_id := "":
	set(value):
		mask_id = value
		update()


func get_svg_string() -> String:
	if mask_id.is_empty():
		return ""
	var children = get_svg_children(self)
	var result = '<mask id="%s">' % mask_id
	result += svg.get_svg_string()
	for child in children:
		result += child.get_svg_string()
	result += '</mask>'
	return result


func get_svg_children(node: Node) -> Array:
	var nodes := []
	for child in node.get_children():
		if (child is SvgMask):
			continue
		if (child is SvgNode) and child.visible:
			nodes.append(child)
		if child.get("visible") and child.get_child_count() > 0:
			nodes.append_array(get_svg_children(child))
	return nodes
