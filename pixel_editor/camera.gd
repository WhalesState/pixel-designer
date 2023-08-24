@tool
extends Camera2D


func _ready():
	var img_size = get_parent().get_node("Sprite").texture.get_image().get_size()
	offset = Vector2(img_size.x, img_size.y) / 2
