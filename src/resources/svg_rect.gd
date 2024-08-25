@tool
class_name SvgRect
extends Svg

@export var position := Vector2.ZERO:
	set(value):
		if value != position:
			position = value
			emit_changed()

@export var size := Vector2(16, 16):
	set(value):
		if value != size:
			size = value
			emit_changed()

@export var corner_radius := Vector2.ZERO:
	set(value):
		if value != corner_radius:
			corner_radius = value
			emit_changed()

@export_range(0.0, 1.0, 0.01) var opacity := 1.0:
	set(value):
		if value != opacity:
			opacity = value
			emit_changed()

@export var fill_color := Color(1.0, 1.0, 1.0, 1.0):
	set(value):
		if value != fill_color:
			fill_color = value
			emit_changed()

@export var stroke_color := Color(0.0, 0.0, 0.0, 0.0):
	set(value):
		if value != stroke_color:
			stroke_color = value
			emit_changed()

@export var stroke_width := 1.0:
	set(value):
		if value != stroke_width:
			stroke_width = value
			emit_changed()

# "miter-clip", "arcs"
@export var stroke_linejoin := LineJoin.MITER:
	set(value):
		if value != stroke_linejoin:
			stroke_linejoin = value
			emit_changed()
# @export_enum("butt", "round", "square") var stroke_linecap := 0

@export var stroke_dash_array: PackedFloat32Array:
	set(value):
		stroke_dash_array = value
		emit_changed()

# stroke-dasharray="20,10,5,5,5,10"
func get_svg_string() -> String:
	var string = '<rect x="%s" y="%s" width="%s" height="%s"' % [position.x, position.y, size.x, size.y]
	if corner_radius.x != 0:
		string += ' rx="%s"' % corner_radius.x
	if corner_radius.y != 0:
		string += ' ry="%s"' % corner_radius.y
	if opacity != 1.0:
		string += ' opacity="%s"' % opacity
	string += ' fill="%s"' % Svg.color_to_html(fill_color)
	if fill_color.a != 1.0:
		string += ' fill-opacity="%s"' % fill_color.a
	string += ' stroke="%s"' % Svg.color_to_html(stroke_color)
	if stroke_width != 1.0:
		string += ' stroke-width="%s"' % stroke_width
	if stroke_color.a != 1.0:
		string += ' stroke-opacity="%s"' % stroke_color.a
	if stroke_linejoin != 0:
		string += ' stroke-linejoin="%s"' % ["round", "bevel"][stroke_linejoin - 1]
	if stroke_dash_array.size() > 1:
		var dash_array = "%s" % stroke_dash_array[0]
		for i in range(1, stroke_dash_array.size()):
			dash_array += ",%s" % stroke_dash_array[i]
		string += ' stroke-dasharray="%s"' % dash_array
	if not mask_id.is_empty():
		string += ' mask="url(#%s)"' % mask_id 
	string += "/>"
	return string
