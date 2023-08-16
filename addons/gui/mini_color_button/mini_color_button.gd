@tool
@icon("./icon.png")
class_name MiniColorButton
extends MarginContainer

signal pressed(col: Color)

@export var color := Color.WHITE:
	set(value):
		color = value
		queue_redraw()

var checker: Checker
# for mouse focus and pressed signal
var color_button := ColButton.new()


func _init(col: Color = color):
	for m in ["left", "right", "top", "bottom"]:
		add_theme_constant_override("margin_%s" % m, 2)
	
	checker = Checker.new(Vector2i(96, 32), Vector2i(2, 2))
	add_child(checker)
	
	color_button.pressed.connect(_color_button_pressed)
	add_child(color_button)
	
	size_flags_horizontal = SIZE_EXPAND | SIZE_SHRINK_CENTER


func _draw():
	# outline
	draw_rect(Rect2i(Vector2i.ONE, Vector2i(size.x - 2, size.y - 2)), Color(0.7, 0.7, 0.7), false, 2)
	# center
	draw_rect(Rect2i(Vector2i(2, 2), Vector2i(size.x - 4, size.y - 4)), color)


func _color_button_pressed():
	emit_signal("pressed", color)


class ColButton:
	extends Button
	
	func _init():
		theme_type_variation = "ColButton"
