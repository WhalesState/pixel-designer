@tool
extends Node2D

var selected = null:
	set(value):
		selected = value
		queue_redraw()


func _draw():
	draw_line(Vector2(0, -100000), Vector2(0, 100000), Color.GREEN)
	draw_line(Vector2(-100000, 0), Vector2(100000, 0), Color.RED)
	if not selected:
		return
	draw_rect(Rect2(selected.position, selected.size), Color(0.0, 1.0, 1.0, 1.0), false)
