@tool
extends TabBox

## current layer button.
@export_range(-1, 64) var selected := 0:
    set(v):
        if v < 0:
            selected = -1
            return
        if tab_container.get_child(tab).get_child(0).get_child_count() - 1 >= v:
            selected = v
            tab_container.get_child(tab).get_child(0).get_child(v).button.button_pressed = true
#			tab_container.get_child(tab).get_child(v).button_pressed = true


func get_container(ind: int) -> HFlowContainer:
    return tab_container.get_child(ind).get_child(0).get_child(0)
