@tool
extends VBoxContainer

var sprite := {}:
	set(value):
		sprite = value
		update_sprite()


func load_sprite(spr: Dictionary):
	sprite = spr


func _ready():
	get_node("%LayerTab").tab_changed.connect(_on_layer_tab_changed)


func _on_layer_tab_changed(ind: int):
	print(ind)


func update_sprite():
	print("update_sprite()")
	update_layers()


func update_layers():
	print("update_layers()")
	get_node("%LayerTab").clear()

	for layer in sprite["layers"].keys():
		var ind = get_node("%LayerTab").add_tab(layer)
		var container = get_node("%LayerTab").get_container(ind)
		var button_group := ButtonGroup.new()
		for img in sprite["layers"][layer][0]:
			var tex := TextureRect.new()
			tex.texture = ImageTexture.create_from_image(img)
			container.add_child(tex)
		
	
	# for child in get_node("%Sprite").get_children():
	#     get_node("%Sprite").remove_child(child)
	#     child.queue_free()
	# for layer in sprite["layers"].keys():
	#     var spr := TextureSprite.new(
	#             Data._layers[layer][0], Data._size, Data.sprite_mat
	#     )
	#     spr.z_index = Data._layers[layer][1]
	#     get_node("%Sprite").add_child(spr)
	#     ind = get_node("%LayerTab").add_tab(layer)
	#     container = get_node("%LayerTab").get_container(ind)
	#     var button_group := ButtonGroup.new()
	#     for img in Data._layers[layer][0]:
	#         var tex := SpriteButton.new(img, Data._size, Data.layer_mat, button_group)
	#         tex.image_changed.connect(_on_image_changed)
	#         container.add_child(tex)
	#         tex.set_meta("ind", ind)
	#     container.get_child(0).button.set_pressed_no_signal(true)
