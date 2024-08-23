@tool
class_name SvgMask
extends SvgNode


func get_svg_string() -> String:
	if mask_id.is_empty():
		return ""
	var children = get_svg_children(self)
	var result = '<defs><mask id="%s">' % mask_id
	for child in children:
		result += child.get_svg_string()
	result += '</mask></defs>'
	return result

# <defs><mask id="mask1"> <rect x="0" y="0" width="100" height="50" fill="white" /></mask></defs>

func get_svg_children(node: Node) -> Array:
	var nodes := []
	for child in node.get_children():
		if child is SvgMask:
			continue
		if child is SvgNode and child.visible:
			nodes.append(child)
		if child.get("visible") and child.get_child_count() > 0:
			nodes.append_array(get_svg_children(child))
	return nodes