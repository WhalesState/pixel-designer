@tool
class_name Svg
extends Resource

enum LineJoin {
	MITER,
	ROUND,
	BEVEL,
}

enum LineCap {
	BUTT,
	ROUND,
	SQUARE,
}

@export var mask_id := "":
	set(value):
		if value != mask_id:
			mask_id = value
			emit_changed()


func get_svg_string() -> String:
	return ""


static func color_to_html(color: Color) -> String:
	var c := color.to_html(false)
	if c[0] == c[1] and c[2] == c[3] and c[4] == c[5]:
		c = c[0] + c[2] + c[4]
	return "#" + c


static func get_header(width: int, height: int, viewbox_position := Vector2i.ZERO, viewbox_size := Vector2i.ZERO) -> String:
	var s := Vector2i(width, height)
	if s.x == 0 or s.y == 0:
		s = Vector2i(32, 32)
	var vp := viewbox_position
	var vs := viewbox_size
	if vs.x == 0 or vs.y == 0:
		vs = s
	return '<svg width="%s" height="%s" viewBox="%s %s %s %s" xmlns="http://www.w3.org/2000/svg">' % [s.x, s.y, vp.x, vp.y, vs.x, vs.y]
