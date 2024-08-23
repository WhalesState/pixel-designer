@tool
class_name SvgEllipse
extends SvgNode

@export var center := Vector2(16, 16):
	set(value):
		if value != center:
			center = value
			update()

@export var radius := Vector2(8, 8):
	set(value):
		if value != radius:
			radius = value
			update()

@export_range(0.0, 1.0, 0.01) var opacity := 1.0:
	set(value):
		if value != opacity:
			opacity = value
			update()

@export var fill_color := Color(1.0, 1.0, 1.0, 1.0):
	set(value):
		if value != fill_color:
			fill_color = value
			update()

@export var stroke_color := Color(0.0, 0.0, 0.0, 0.0):
	set(value):
		if value != stroke_color:
			stroke_color = value
			update()

@export var stroke_width := 1.0:
	set(value):
		if value != stroke_width:
			stroke_width = value
			update()


func get_svg_string():
	var string = '<ellipse cx="%s" cy="%s" rx="%s" ry="%s"' % [center.x, center.y, radius.x, radius.y]
	if opacity != 1.0:
		string += ' opacity="%s"' % opacity
	string += ' fill="%s"' % color_to_html(fill_color)
	if fill_color.a != 1.0:
		string += ' fill-opacity="%s"' % fill_color.a
	if stroke_color != Color(0.0, 0.0, 0.0, 0.0):
		string += ' stroke="%s"' % color_to_html(stroke_color)
	if stroke_width != 1.0:
		string += ' stroke-width="%s"' % stroke_width
	if stroke_color.a != 1.0:
		string += ' stroke-opacity="%s"' % stroke_color.a
	if not mask_id.is_empty():
		string += ' mask="url(#%s)"' % mask_id
	string += "/>"
	return string
