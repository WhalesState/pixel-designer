@tool
extends Sprite2D

var checker: Checker


func _ready():
	var sprite_size = texture.get_image().get_size()
	checker = Checker.new(Vector2i(sprite_size.x , sprite_size.y), Vector2i(16, 16))
	add_child(checker, true, INTERNAL_MODE_FRONT)
