@tool
extends Camera2D

var is_pan := false

@onready var sprite: Sprite2D = get_node("%MainSprite")
@onready var vp_sprite: Sprite2D = get_node("%Sprite")


func _input(ev: InputEvent):
    if not (ev is InputEventMouseMotion or ev is InputEventMouseButton):
        return
    
    if ev is InputEventMouseMotion and is_pan:
        position -= ev.relative / zoom
        get_viewport().set_input_as_handled()
    
    if ev is InputEventMouseButton:
        if ev.button_index == MOUSE_BUTTON_MIDDLE:
            is_pan = ev.pressed
            get_viewport().set_input_as_handled()
        if ev.is_pressed():
            if ev.button_index == MOUSE_BUTTON_WHEEL_UP:
                cam_zoom(1)
                get_viewport().set_input_as_handled()
            elif ev.button_index == MOUSE_BUTTON_WHEEL_DOWN:
                cam_zoom(-1)
                get_viewport().set_input_as_handled()


func cam_zoom(value: int):
    var old_zoom := zoom.x
    var new_zoom := old_zoom + value
    new_zoom = clamp(new_zoom, 1, 64)
    var mpos = get_viewport().get_mouse_position().clamp(
            vp_sprite.get_canvas_transform().origin,
            vp_sprite.get_canvas_transform().origin + Vector2(sprite.checker.image_size) * zoom
    ).floor()
    var cur_pos = -get_viewport_rect().size / 2 + mpos
    zoom = Vector2(new_zoom, new_zoom)
    position -= cur_pos / new_zoom - cur_pos / old_zoom


func _on_focus_camera_pressed():
    position = sprite.checker.image_size / 2
