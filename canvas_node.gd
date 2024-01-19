@tool
extends Node2D

@onready var vp_container: SubViewportContainer = get_node("%ViewportContainer")


func _ready():
    vp_container.resized.connect(_on_viewport_resized)


func _draw():
    draw_rect(Rect2(Vector2.ZERO, vp_container.size), Color(1.0, 1.0, 1.0, 0.5), false)


func _on_viewport_resized():
    queue_redraw()
