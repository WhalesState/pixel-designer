@tool
extends TabBox

var sprites := {}


func add_layer(tab_name: String, spr: Sprite2D) -> int:
    sprites[tab_name] = spr
    return add_tab(tab_name)


func get_container(ind := -1) -> HFlowContainer:
    if ind == -1:
        ind = tab
    return tab_container.get_child(ind).get_child(0).get_child(0)


func _on_cell_button_pressed(texture: ImageTexture, layer_name: String):
    sprites[layer_name].texture = texture
