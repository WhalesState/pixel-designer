@tool
class_name SvgLine
extends Svg

# Known issue: if start_position.x is nearly equal zero or smaller, it produces a render artifact.

@export var start_position := Vector2(4, 4):
	set(value):
		if value != start_position:
			start_position = value
			emit_changed()

@export var end_position := Vector2(32, 32):
	set(value):
		if value != end_position:
			end_position = value
			emit_changed()

@export_range(0.0, 1.0, 0.01) var opacity := 1.0:
	set(value):
		if value != opacity:
			opacity = value
			emit_changed()

@export var stroke_color := Color(1.0, 1.0, 1.0, 1.0):
	set(value):
		if value != stroke_color:
			stroke_color = value
			emit_changed()

@export var stroke_width := 4.0:
	set(value):
		if value != stroke_width:
			stroke_width = value
			emit_changed()

@export var stroke_linecap := LineCap.BUTT:
	set(value):
		if value != stroke_linecap:
			stroke_linecap = value
			emit_changed()

@export var stroke_dash_array := PackedFloat32Array([0]):
	set(value):
		stroke_dash_array = value
		emit_changed()

func get_svg_string() -> String:
	var result = '<line x1="%s" y1="%s" x2="%s" y2="%s"' % [start_position.x, start_position.y, end_position.x, end_position.y]
	if opacity != 1.0:
		result += ' opacity="%s"' % opacity
	result += ' stroke="%s"' % Svg.color_to_html(stroke_color)
	if stroke_width != 1.0:
		result += ' stroke-width="%s"' % stroke_width
	if stroke_color.a != 1.0:
		result += ' stroke-opacity="%s"' % stroke_color.a
	if stroke_linecap != 0:
		result += ' stroke-linecap="%s"' % ["round", "square"][stroke_linecap - 1]
	# if stroke_dash_array.size() > 1:
	# 	var dash_array = "%s" % stroke_dash_array[0]
	# 	for i in range(1, stroke_dash_array.size()):
	# 		dash_array += ",%s" % stroke_dash_array[i]
	# 	result += ' stroke-dasharray="%s"' % dash_array
	if not mask_id.is_empty():
		result += ' mask="url(#%s)"' % mask_id 
	result += "/>"
	return result