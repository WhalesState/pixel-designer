@tool
extends Sprite2D

var checker: Checker


func _init():
    checker = Checker.new(Vector2i(16 , 16), Vector2i(1, 1))
    add_child(checker, true, INTERNAL_MODE_FRONT)
