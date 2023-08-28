@tool
@icon("./icon.png")
class_name Checker
extends TextureRect

## Checker image size.
@export var image_size := Vector2i(16, 16):
    set(value):
        image_size = value.clamp(Vector2i.ONE, Vector2i(1024, 1024))
        update_size()

## Checker cell size.
@export var checker_size := Vector2i(4, 4):
    set(value):
        checker_size = value.clamp(Vector2i.ONE, image_size)
        if material:
            material.set_shader_parameter("size", checker_size)


## Update the checker image size.
func update_size():
    var img := Image.create(image_size.x, image_size.y, false, Image.FORMAT_RGBA8)
    img.fill(Color.WHITE)
    texture = ImageTexture.create_from_image(img)
    if material:
        material.set_shader_parameter("texture_size", image_size)
    size = image_size


func _init(new_image_size: Vector2i = image_size, new_checker_size: Vector2i = checker_size):
    show_behind_parent = true
    # Apply material.
    material = ShaderMaterial.new()
    material.shader = load("res://addons/gui/shaders/checker.gdshader")
    # Set cell and image size.
    image_size = new_image_size
    checker_size = new_checker_size
    mouse_filter = Control.MOUSE_FILTER_IGNORE
