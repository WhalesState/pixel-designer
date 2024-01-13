@tool
extends TabBox

var sprites := {}
var cur_cell := -1


func add_layer(tab_name: String, spr: Sprite2D) -> int:
    sprites[tab_name] = spr
    return add_tab(tab_name)


func get_pressed_cell_button():
    return get_container().get_child(0).button_group.get_pressed_button()
