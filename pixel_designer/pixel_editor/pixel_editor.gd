@tool
extends VBoxContainer

@export var checker_size := Vector2i(4, 4):
    set(value):
        checker_size = value
        if sprite:
            sprite.checker.checker_size = checker_size

@onready var camera: Camera2D = get_node("%Camera")
@onready var sprite: Sprite2D = get_node("%MainSprite")
@onready var vp_sprite: Sprite2D = get_node("%Sprite")


func _init():
    theme_type_variation = "OutlinePanel"


func _ready():
    checker_size = Vector2i(8, 8)
