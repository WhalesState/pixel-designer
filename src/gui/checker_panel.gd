@tool
class_name CheckerPanel
extends PanelContainer

@export var checker_size := Vector2i(8, 8):
	set(value):
		value.x = clamp(value.x, 1, 32)
		value.y = clamp(value.y, 1, 32)
		if value != checker_size:
			checker_size = value
			needs_update = true
			queue_redraw()

@export var checker_light_color := Color(0.8, 0.8, 0.8, 1):
	set(value):
		if value != checker_light_color:
			checker_light_color = value
			needs_update = true
			queue_redraw()

@export var checker_dark_color := Color(0.4, 0.4, 0.4, 1):
	set(value):
		if value != checker_dark_color:
			checker_dark_color = value
			needs_update = true
			queue_redraw()

var needs_update := true
var stylebox := StyleBoxTexture.new()
var img = Image.new()


func _init():
	add_theme_stylebox_override("panel", stylebox)
	stylebox.axis_stretch_horizontal = StyleBoxTexture.AXIS_STRETCH_MODE_TILE
	stylebox.axis_stretch_vertical = StyleBoxTexture.AXIS_STRETCH_MODE_TILE


func _draw():
	await get_tree().process_frame
	if needs_update:
		_update_checker()


func _update_checker():
	var x = checker_size.x
	var y = checker_size.y
	img = Image.create(x * 2, y * 2, false, Image.FORMAT_RGBA8)
	img.fill(checker_dark_color)
	img.fill_rect(Rect2i(0, 0, x, y), checker_light_color)
	img.fill_rect(Rect2i(x, y, x, y), checker_light_color)
	stylebox.texture = ImageTexture.create_from_image(img)
	needs_update = false
