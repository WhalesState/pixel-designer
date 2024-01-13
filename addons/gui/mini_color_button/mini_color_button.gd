@tool
@icon("./icon.png")
class_name MiniColorButton
extends MarginContainer

## emits when button is pressed.
signal pressed(col: Color)

## button's color.
@export var color := Color.WHITE:
    set(value):
        color = value
        queue_redraw()

## disables the color button.
@export var disabled := false:
    set(value):
        disabled = value
        button.set_deferred("disabled", disabled)
        modulate.a = 0.5 if disabled else 1.0
        size_flags_horizontal = SIZE_FILL if disabled else SIZE_EXPAND_FILL
        queue_redraw()

## checker shader.
var checker_shader = preload("res://addons/gui/shaders/checker.gdshader")
## the panel contains the checker and the button.
var panel_checker := PanelContainer.new()
## the the color button.
var button := ColButton.new()
## sets the button pressed.
var button_pressed := false:
    set(value):
        button_pressed = value
        queue_redraw()


func _init(col: Color = color):
    for m in ["left", "right", "top", "bottom"]:
        add_theme_constant_override("margin_%s" % m, 2)
    custom_minimum_size = Vector2i(32, 32)
    var style = StyleBoxFlat.new()
    panel_checker.material = ShaderMaterial.new()
    panel_checker.material.shader = checker_shader
    panel_checker.material.set_shader_parameter("size", Vector2i(8, 8))
    panel_checker.add_theme_stylebox_override("panel", style)
    panel_checker.show_behind_parent = true
    add_child(panel_checker)
    button.toggled.connect(_color_button_toggled)
    add_child(button)
    resized.connect(_on_resized)


func _on_resized():
    panel_checker.material.set_shader_parameter("texture_size", size.floor())


func _draw():
    # outline
    var outline_color = Color.BLACK if color.v >= 0.5 else Color.WHITE
    draw_rect(Rect2i(Vector2i.ONE, Vector2i(size.x - 2, size.y - 2)), outline_color, false, 2)
    # color
    if disabled:
        # draw_line(Vector2i(2, 2), Vector2i(size.x - 2, size.y - 2), Color.RED, 2)
        draw_line(Vector2i(size.x - 2, 2), Vector2i(2, size.y - 2), Color.RED, 2)
    else:
        draw_rect(Rect2i(Vector2i(2, 2), Vector2i(size.x - 4, size.y - 4)), color)
        if button_pressed:
            draw_circle(Vector2(8, 8), 4, outline_color)


## called when the button is toggled.
func _color_button_toggled(_pressed: bool):
    button_pressed = _pressed
    if _pressed:
        emit_signal("pressed", color)


## The color button class.
class ColButton:
    extends Button
    
    func _init():
        theme_type_variation = "ColButton"
