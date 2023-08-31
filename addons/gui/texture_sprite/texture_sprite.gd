@tool
@icon("./icon.png")
class_name TextureSprite
extends TextureRect

@export var frame_size := Vector2(16, 16):
    set(value):
        frame_size = value.clamp(Vector2i(1, 1), Vector2i(1024, 1024))
        if texture:
            _update()
        if material:
            material.set_shader_parameter("frame_size", frame_size)

@export_range(0, 1024) var frame := 0:
    set(value):
        frame = clampi(value, 0, frame_count - 1)
        if material:
            material.set_shader_parameter("frame", frame)

var h_frames := 1:
    set(value):
        h_frames = value
        if material:
            material.set_shader_parameter("h_frames", h_frames)

var v_frames := 1:
    set(value):
        v_frames = value
        if material:
            material.set_shader_parameter("v_frames", v_frames)

var frame_count := 0


func _init(spr_size := Vector2i(24, 24)):
    material = Constants.LAYER_BUTTON_MATERIAL
    expand_mode = EXPAND_IGNORE_SIZE
    stretch_mode = STRETCH_TILE
    frame_size = spr_size
    custom_minimum_size = frame_size


func _notification(what: int):
    if what == NOTIFICATION_RESIZED:
        if material:
            material.set_shader_parameter("rect_size", size)


func _set(property: StringName, value: Variant):
    if property == "texture":
        texture = value
        if texture:
            _update()


func _update():
    var img_size = texture.get_image().get_size()
    h_frames = floor(img_size.x / frame_size.x)
    v_frames = floor(img_size.y / frame_size.y)
    custom_minimum_size = frame_size
    frame_count = h_frames * v_frames
    frame = 0
