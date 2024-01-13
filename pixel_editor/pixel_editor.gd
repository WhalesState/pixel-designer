@tool
extends VBoxContainer

signal image_edited(image: Image)

enum {
    TOOL_PENCIL,
    TOOL_FILL,
    TOOL_LINE,
    TOOL_RECT,
    TOOL_ELLIPSE,
    TOOL_MOVE,
    TOOL_SELECT,
}

const tools = [TOOL_PENCIL, TOOL_FILL, TOOL_LINE, TOOL_RECT, TOOL_ELLIPSE, TOOL_MOVE, TOOL_SELECT]

@export var checker_size := Vector2i(4, 4):
    set(value):
        checker_size = value
        if sprite:
            sprite.checker.checker_size = checker_size

var focused := false
var left_pressed := false
var right_pressed := false
var shift_pressed := false
var ctrl_pressed := false
var alt_pressed := false
var left_color := Color.WHITE
var right_color := Color.TRANSPARENT
var color := left_color
var start_pos := Vector2i.ZERO
var last_pos := Vector2i.ZERO
var prev_pos := -Vector2i.ONE
var cur_tool := TOOL_PENCIL
var cur_layer := -1
var img: Image
var helper_img: Image:
    set(value):
        helper_img = value
        if sprite:
            sprite.texture = ImageTexture.create_from_image(helper_img)

@onready var camera: Camera2D = get_node("%Camera")
@onready var sprite: Sprite2D = get_node("%MainSprite")
@onready var vp_sprite: Sprite2D = get_node("%Sprite")
@onready var editor: Node2D = get_node("%Editor")


func _ready():
    checker_size = Vector2i(8, 8)
    for child in get_node("%ToolsBox").get_children():
        child.connect("pressed", _on_tool_changed.bind(child.get_index()))


func _on_editor_gui_input(ev: InputEvent):
    if ev is InputEventKey:
        if not ev.keycode in [KEY_SHIFT, KEY_ALT, KEY_CTRL] or ev.is_echo():
            return
        var m_pos := Vector2i(editor.get_global_mouse_position())
        if ev.keycode == KEY_SHIFT:
            shift_pressed = ev.pressed
            if cur_tool == TOOL_PENCIL:
                if ev.pressed:
                    clear_helper()
                    helper_img.set_pixel_line_v(last_pos, m_pos, left_color)
                    update_helper()
                else:
                    clear_helper()
        elif ev.keycode == KEY_ALT:
            alt_pressed = ev.pressed
        elif ev.keycode == KEY_CTRL:
            ctrl_pressed = ev.pressed
        if cur_tool in [TOOL_RECT, TOOL_ELLIPSE]:
            if left_pressed or right_pressed:
                clear_helper()
                if cur_tool == TOOL_RECT:
                    helper_img.set_pixel_rect_v(last_pos, m_pos, left_color, alt_pressed, shift_pressed, ctrl_pressed)
                else:
                    helper_img.set_pixel_ellipse_v(last_pos, m_pos, left_color, alt_pressed, shift_pressed, ctrl_pressed)
                update_helper()
        get_viewport().set_input_as_handled()
    elif ev is InputEventMouseMotion:
        var m_pos := Vector2i(editor.get_global_mouse_position())
        if m_pos == prev_pos:
            return
        prev_pos = m_pos
        var pos := m_pos + start_pos
        if left_pressed or right_pressed:
            if cur_tool == TOOL_PENCIL:
                img.set_pixel_line_v(last_pos + start_pos, pos, color)
                last_pos = m_pos
                update_texture()
            elif cur_tool == TOOL_LINE:
                clear_helper()
                helper_img.set_pixel_line_v(last_pos, m_pos, left_color)
                update_helper()
            elif cur_tool in [TOOL_RECT, TOOL_ELLIPSE]:
                clear_helper()
                if cur_tool == TOOL_RECT:
                    helper_img.set_pixel_rect_v(last_pos, m_pos, left_color, alt_pressed, shift_pressed, ctrl_pressed)
                else:
                    helper_img.set_pixel_ellipse_v(last_pos, m_pos, left_color, alt_pressed, shift_pressed, ctrl_pressed)
                update_helper()
            get_viewport().set_input_as_handled()
        else:
            if cur_tool == TOOL_PENCIL:
                if shift_pressed:
                    clear_helper()
                    helper_img.set_pixel_line_v(last_pos, m_pos, left_color)
                    update_helper()
    elif ev is InputEventMouseButton:
        if not ev.button_index in [MOUSE_BUTTON_LEFT, MOUSE_BUTTON_RIGHT]:
            return
        if ev.button_index == MOUSE_BUTTON_LEFT:
            left_pressed = ev.pressed
        elif ev.button_index == MOUSE_BUTTON_RIGHT:
            right_pressed = ev.pressed
        var m_pos := Vector2i(editor.get_global_mouse_position())
        var pos := m_pos + start_pos
        if ev.is_pressed():
            color = left_color if left_pressed else right_color
        if cur_tool == TOOL_PENCIL:
            if ev.is_pressed():
                if shift_pressed:
                    img.set_pixel_line_v(last_pos + start_pos, pos, color)
                else:
                    img.set_pixel_v(pos, color)
                last_pos = m_pos
                update_texture()
        elif cur_tool == TOOL_LINE:
            if ev.is_pressed():
                helper_img.set_pixel_v(m_pos, left_color)
                update_helper()
                last_pos = m_pos
            else:
                clear_helper()
                img.set_pixel_line_v(last_pos + start_pos, pos, color)
                update_texture()
                last_pos = m_pos
        elif cur_tool in [TOOL_RECT, TOOL_ELLIPSE]:
            if ev.is_pressed():
                helper_img.set_pixel_v(m_pos, left_color)
                update_helper()
                last_pos = m_pos
            else:
                clear_helper()
                if cur_tool == TOOL_RECT:
                    img.set_pixel_rect_v(last_pos + start_pos, pos, color, alt_pressed, shift_pressed, ctrl_pressed)
                else:
                    img.set_pixel_ellipse_v(last_pos + start_pos, pos, color, alt_pressed, shift_pressed, ctrl_pressed)
                update_texture()
                last_pos = m_pos
        get_viewport().set_input_as_handled()


func update_helper():
    sprite.texture = ImageTexture.create_from_image(helper_img)


func clear_helper():
    helper_img.fill(Color.TRANSPARENT)
    update_helper()


func update_texture():
    sprite.get_child(cur_layer).texture = ImageTexture.create_from_image(img)
    clear_helper()
    emit_signal("image_edited", img)


func _on_tool_changed(index: int):
    cur_tool = tools[index]


func _on_anim_editor_frame_changed(frame: int):
    for child in sprite.get_children():
        child.frame = frame
    var spr: Sprite2D = sprite.get_child(cur_layer)
    start_pos = spr.frame_coords * Vector2i(spr.get_rect().size)
    img.set_selection_rect(start_pos, Vector2i(spr.get_rect().size))


func _on_focus_entered(entered: bool):
    focused = entered
    var col := Color("42c2ff") if focused else Color.WHITE
    get_node("%EditorPanel").self_modulate = col


func _on_mouse_entered(entered: bool):
    if entered:
        get_node("%EditorPanel").get_child(0).grab_focus()
    else:
        get_node("%EditorPanel").get_child(0).release_focus()
