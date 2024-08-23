@tool
class_name SvgTextureRect
extends TextureRect

var update_texture := false
var needs_update := false

@export_range(1, 2048) var width = 32:
	set(value):
		if value != width:
			width = value
			update_texture = true
			redraw()

@export_range(1, 2048) var height = 32:
	set(value):
		if value != height:
			height = value
			update_texture = true
			redraw()

@export var viewbox_position := Vector2i.ZERO:
	set(value):
		if value != viewbox_position:
			viewbox_position = value
			redraw()

@export var viewbox_size := Vector2i(32, 32):
	set(value):
		if value != viewbox_size:
			viewbox_size = value
			redraw()

@export_range(0.1, 5.0) var svg_scale = 1.0:
	set(value):
		if value != svg_scale:
			svg_scale = value
			update_texture = true
			redraw()


func draw():
	if not needs_update:
		return
	if not is_visible_in_tree():
		return
	var svg = get_svg()
	var img = Image.new()
	img.load_svg_from_string(svg, svg_scale)
	if not texture or update_texture:
		texture = ImageTexture.create_from_image(img)
		update_texture = false
	else:
		texture.update(img)
	needs_update = false


func redraw() -> void:
	if not needs_update:
		needs_update = true


func get_svg() -> String:
	var svg := '<svg width="%s" height="%s" viewBox="%s %s %s %s" xmlns="http://www.w3.org/2000/svg">' % [width, height, viewbox_position.x, viewbox_position.y, viewbox_size.x, viewbox_size.y]
	svg += get_svg_string()
	svg += "</svg>"
	print(svg)
	return svg


func get_svg_string() -> String:
	var result = ""
	var svg_nodes := get_svg_children(self)
	for node in svg_nodes:
		result += node.get_svg_string()
	return result


func get_svg_children(node: Node) -> Array:
	var nodes := []
	for child in node.get_children():
		if child is SvgNode and child.visible:
			nodes.append(child)
		if not (child is SvgMask) and child.get("visible") and child.get_child_count() > 0:
			nodes.append_array(get_svg_children(child))
	return nodes


func _notification(what: int) -> void:
	if what == NOTIFICATION_CHILD_ORDER_CHANGED:
		redraw()


func _set(property: StringName, _value: Variant) -> bool:
	if property == "texture":
		return true
	return false


func _validate_property(property: Dictionary) -> void:
	if property.name == "texture":
		property.usage = PROPERTY_USAGE_NONE


func _enter_tree() -> void:
	redraw()


func _init() -> void:
	RenderingServer.frame_pre_draw.connect(draw)
