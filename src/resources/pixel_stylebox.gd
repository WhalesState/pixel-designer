@tool
class_name PixelStyleBox
extends StyleBox

var needs_update = true

@export var fill_color := Color(1, 1, 1, 1.0):
	set(value):
		if value != fill_color:
			fill_color = value
			update()

@export_range(0, 3) var border_width := 0:
	set(value):
		if value != border_width:
			border_width = value
			update()

@export var border_color := Color(0.6, 0.6, 0.6, 0.0):
	set(value):
		if value != border_color:
			border_color = value
			update()

@export var border_linejoin := Svg.LineJoin.MITER:
	set(value):
		if value != border_linejoin:
			border_linejoin = value
			update()

@export var flat_corners := false:
	set(value):
		if value != flat_corners:
			flat_corners = value
			update()

@export var scale := 1.0:
	set(value):
		if value != scale:
			scale = value
			update()

@export_group("Corner Radius")

@export_range(0, 8) var corner_top_left := 0:
	set(value):
		if value != corner_top_left:
			corner_top_left = value
			update()

@export_range(0, 8) var corner_top_right := 0:
	set(value):
		if value != corner_top_right:
			corner_top_right = value
			update()

@export_range(0, 8) var corner_bottom_right := 0:
	set(value):
		if value != corner_bottom_right:
			corner_bottom_right = value
			update()

@export_range(0, 8) var corner_bottom_left := 0:
	set(value):
		if value != corner_bottom_left:
			corner_bottom_left = value
			update()

@export_group("Expand")

@export_range(0, 16) var expand_left := 0:
	set(value):
		if value != expand_left:
			expand_left = value
			update()

@export_range(0, 16) var expand_top := 0:
	set(value):
		if value != expand_top:
			expand_top = value
			update()

@export_range(0, 16) var expand_right := 0:
	set(value):
		if value != expand_right:
			expand_right = value
			update()

@export_range(0, 16) var expand_bottom := 0:
	set(value):
		if value != expand_bottom:
			expand_bottom = value
			update()

@export_group("Grow")

@export_range(0, 16) var grow_left := 0:
	set(value):
		if value != grow_left:
			grow_left = value
			update()

@export_range(0, 16) var grow_top := 0:
	set(value):
		if value != grow_top:
			grow_top = value
			update()

@export_range(0, 16) var grow_right := 0:
	set(value):
		if value != grow_right:
			grow_right = value
			update()

@export_range(0, 16) var grow_bottom := 0:
	set(value):
		if value != grow_bottom:
			grow_bottom = value
			update()

func set_corner_all(value: int) -> void:
	corner_top_left = value
	corner_top_right = value
	corner_bottom_right = value
	corner_bottom_left = value


func update():
	if not needs_update:
		needs_update = true
		emit_changed()

var texture_margin_left: float
var texture_margin_right: float
var texture_margin_top: float
var texture_margin_bottom: float

var texture: ImageTexture


func _draw(rid: RID, rect: Rect2) -> void:
	# Generate texture.
	if needs_update:
		var svg := Svg.get_header(16, 16)
		svg += '<path fill="%s" fill-opacity="%s"' % [Svg.color_to_html(fill_color), fill_color.a]
		if border_width > 0 and border_color.a > 0.0:
			svg += ' stroke="%s" stroke-opacity="%s" stroke-width="%s"' % [Svg.color_to_html(border_color), border_color.a, border_width]
			svg += 'stroke-linejoin="%s"' % ["miter", "round", "bevel"][border_linejoin]
		svg += ' d="'
		var b := Vector2(border_width, border_width) / 2.0
		# Top Left corner.
		var c := Vector2(corner_top_left, corner_top_left) / 2.0
		if c.x > 0:
			c.x = maxf(c.x, b.x)
			c.y = maxf(c.y, b.y)
		var e := Vector2(expand_left, expand_top)
		var start := Vector2(b.x - e.x, minf(b.y + c.y - e.y, 8.0))
		var prev := Vector2.ZERO
		var next := start
		svg += 'M %s,%s' % [start.x, start.y]
		if c.x > 0:
			next = Vector2(minf(b.x + c.x - e.x, 8.0), b.y - e.y)
			if flat_corners:
				svg += ' L %s,%s' % [next.x, next.y]
			else:
				svg += ' Q %s,%s %s,%s' % [b.x - e.x, b.y - e.y, next.x, next.y]
		# Top Right corner.
		c = Vector2(corner_top_right, corner_top_right) / 2.0
		if c.x > 0:
			c.x = maxf(c.x, b.x)
			c.y = maxf(c.y, b.y)
		e = Vector2(expand_right, expand_top)
		prev = next
		next = Vector2(maxf(16 - b.x - c.x + e.x, 8.0), minf(b.y - e.y, 8.0))
		if prev != next:
			svg += ' L %s,%s' % [next.x, next.y]
		if c.x > 0:
			next = Vector2(16 - b.x + e.x, minf(b.y + c.y - e.y, 8.0))
			if flat_corners:
				svg += ' L %s,%s' % [next.x, next.y]
			else:
				svg += ' Q %s,%s %s,%s' % [16 - b.x + e.x, b.y - e.y, next.x, next.y]
		# Bottom Right corner.
		c = Vector2(corner_bottom_right, corner_bottom_right) / 2.0
		if c.x > 0:
			c.x = maxf(c.x, b.x)
			c.y = maxf(c.y, b.y)
		e = Vector2(expand_right, expand_bottom)
		prev = next
		next = Vector2(16 - b.x + e.x, maxf(16 - b.y - c.y + e.y, 8.0))
		if prev != next:
			svg += ' L %s,%s' % [next.x, next.y]
		if c.x > 0:
			next = Vector2(maxf(16 - b.x - c.x + e.x, 8.0), 16 - b.y + e.y)
			if flat_corners:
				svg += ' L %s,%s' % [next.x, next.y]
			else:
				svg += ' Q %s,%s %s,%s' % [16 - b.x + e.x, 16 - b.y + e.y, next.x, next.y]
		# Bottom Left corner.
		c = Vector2(corner_bottom_left, corner_bottom_left) / 2.0
		if c.x > 0:
			c.x = maxf(c.x, b.x)
			c.y = maxf(c.y, b.y)
		e = Vector2(expand_left, expand_bottom)
		prev = next
		next = Vector2(minf(b.x + c.x - e.x, 8.0), 16 - b.y + e.y)
		if prev != next:
			svg += ' L %s,%s' % [next.x, next.y]
		if c.x > 0:
			next = Vector2(b.x - e.x, maxf(16 - b.y - c.y + e.y, 8.0))
			if flat_corners:
				if start != next:
					svg += ' L %s,%s' % [next.x, next.y]
				else:
					# Fix render issue when start point is equal end point.
					if border_linejoin == Svg.LineJoin.MITER:
						svg = svg.replace('stroke-linejoin="miter"', 'stroke-linejoin="round"')
			else:
				svg += ' Q %s,%s %s,%s' % [b.x - e.x, 16 - b.y + e.y, next.x, next.y]
		svg += ' Z"/></svg>'
		var image := Image.new()
		image.load_svg_from_string(svg, scale)
		texture = ImageTexture.create_from_image(image)
		needs_update = false
	# Calculate texture margin.
	var tm_left = maxi(border_width, ceili(maxi(border_width + corner_top_left, border_width + corner_bottom_left) / 2.0))
	var tm_right = maxi(border_width, ceili(maxi(border_width + corner_top_right, border_width + corner_bottom_right) / 2.0))
	var tm_top = maxi(border_width, ceili(maxi(border_width + corner_top_left, border_width + corner_top_right) / 2.0))
	var tm_bottom = maxi(border_width, ceili(maxi(border_width + corner_bottom_left, border_width + corner_bottom_right) / 2.0))
	texture_margin_left = maxi(tm_left - expand_left, 0) * scale
	texture_margin_right = maxi(tm_right - expand_right, 0) * scale
	texture_margin_top = maxi(tm_top - expand_top, 0) * scale
	texture_margin_bottom = maxi(tm_bottom - expand_bottom, 0) * scale
	RenderingServer.canvas_item_add_nine_patch(rid, _get_draw_rect(rect), Rect2(Vector2.ZERO, texture.get_size()), texture.get_rid(), Vector2(texture_margin_left, texture_margin_top), Vector2(texture_margin_right, texture_margin_bottom))


func _get_draw_rect(rect: Rect2) -> Rect2:
	return rect.grow_individual(grow_left, grow_top, grow_right, grow_bottom)


func _get_style_margin(side: Side) -> float:
	var margin := 0.0
	match side:
		SIDE_LEFT:
			margin = maxf(texture_margin_left - grow_left, 0)
		SIDE_TOP:
			margin = maxf(texture_margin_top - grow_top, 0)
		SIDE_RIGHT:
			margin = maxf(texture_margin_right - grow_right, 0)
		SIDE_BOTTOM:
			margin = maxf(texture_margin_bottom - grow_bottom, 0)
	return margin
