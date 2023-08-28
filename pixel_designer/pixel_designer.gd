@tool
extends VBoxContainer

const GLOBAL = preload("./global.gd")

var sprite := {}:
    set(value):
        sprite = value
        update_sprite()

@onready var layers_tab: TabBox = get_node("%LayerTab")
@onready var pixel_editor = get_node("%PixelEditor")


func load_sprite(spr: Dictionary):
    sprite = spr
    pixel_editor.sprite.checker.image_size = sprite["size"]
    pixel_editor.camera._on_focus_camera_pressed()


func _ready():
    layers_tab.tab_changed.connect(_on_layer_tab_changed)


func _on_layer_tab_changed(ind: int):
    if sprite:
        print(ind)


func update_sprite():
    print("update_sprite()")
    update_layers()


func update_layers():
    print("update_layers()")
    layers_tab.clear()
    for layer in sprite["layers"].keys():
        var ind = layers_tab.add_tab(layer)
        var container = layers_tab.get_container(ind)
        var button_group := ButtonGroup.new()
        for img in sprite["layers"][layer][0]:
            var layer_button := GLOBAL.LayerButton.new(sprite["size"], img)
            layer_button.button_group = button_group
            container.add_child(layer_button)
        container.get_child(0).button_pressed = true
    
    
# func _input(ev: InputEvent):
# 	if not (ev is InputEventKey and ev.is_pressed()):
# 		return
# 	if ev.keycode == KEY_F:
# 		# pixel_editor.camera.position = sprite["size"] / 2
# 		pixel_editor.camera.focus()
# 		get_viewport().set_input_as_handled()
    
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
