@tool
@icon("./icon.png")
class_name Checker
extends TextureRect

## Checker image size.
@export var image_size := Vector2i(16, 16):
	set(value):
		value.x = clampi(value.x, 1, 1024)
		value.y = clampi(value.y, 1, 1024)
		image_size = value
		update_size()

## Checker cell size.
@export var cell_size := Vector2i(4, 4):
	set(value):
		value.x = clampi(value.x, 1, 128)
		value.y = clampi(value.y, 1, 128)
		cell_size = value
		material.set_shader_parameter("size", cell_size)


## Update the checker image size.
func update_size():
	var img := Image.create(image_size.x, image_size.y, false, Image.FORMAT_RGBA8)
	img.fill(Color.WHITE)
	texture = ImageTexture.create_from_image(img)
	material.set_shader_parameter("texture_size", image_size)
	size = image_size


func _init(new_image_size := image_size, new_checker_size := cell_size):
	show_behind_parent = true
	# Apply material.
	material = ShaderMaterial.new()
	material.shader = preload("./checker.gdshader")
	# Set cell and image size.
	image_size = new_image_size
	cell_size = new_checker_size
