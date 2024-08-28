@tool
class_name CheckerStyleBox
extends StyleBox

var needs_update = true

@export var visible := true:
	set(value):
		if value != visible:
			visible = value
			update()

@export_range(1, 64) var checker_size := 4:
	set(value):
		if value != checker_size:
			checker_size = value
			update()

@export_color_no_alpha var checker_light_color := Color(0.8, 0.8, 0.8):
	set(value):
		value.a = 1.0
		if value != checker_light_color:
			checker_light_color = value
			update()

@export_color_no_alpha var checker_dark_color := Color(0.4, 0.4, 0.4):
	set(value):
		value.a = 1.0
		if value != checker_dark_color:
			checker_dark_color = value
			update()

@export_range(1, 16) var scale := 1:
	set(value):
		if value != scale:
			scale = value
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

var texture : ImageTexture


func set_grow_all(value: int) -> void:
	grow_left = value
	grow_top = value
	grow_right = value
	grow_bottom = value


func update():
	if not needs_update:
		needs_update = true
		emit_changed()


func _draw(rid: RID, rect: Rect2) -> void:
	if not visible:
		needs_update = false
		return
	# Generate texture.
	if needs_update:
		var svg := Svg.get_header(checker_size * 2, checker_size * 2)
		svg += '<rect x="0" y="0" width="%s" height="%s" fill="%s"/>' % [checker_size, checker_size, Svg.color_to_html(checker_light_color)]
		svg += '<rect x="%s" y="0" width="%s" height="%s" fill="%s"/>' % [checker_size, checker_size, checker_size, Svg.color_to_html(checker_dark_color)]
		svg += '<rect x="%s" y="%s" width="%s" height="%s" fill="%s"/>' % [checker_size, checker_size, checker_size, checker_size, Svg.color_to_html(checker_light_color)]
		svg += '<rect x="0" y="%s" width="%s" height="%s" fill="%s"/>' % [checker_size, checker_size, checker_size, Svg.color_to_html(checker_dark_color)]
		svg += '</svg>'
		var img = Image.new()
		img.load_svg_from_string(svg, scale)
		texture = ImageTexture.create_from_image(img)
		needs_update = false
	RenderingServer.canvas_item_add_texture_rect(rid, _get_draw_rect(rect), texture.get_rid(), true)


func _get_draw_rect(rect: Rect2) -> Rect2:
	return rect.grow_individual(grow_left, grow_top, grow_right, grow_bottom)
