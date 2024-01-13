@tool
extends TabBox

var cur_palette := 0

# cur_material: Array = [
#   [
#       0: material_name,
#       1: color_ids [
#           0: outlines[int],
#           1: colors[int],
#           2: highlight[int],
#           3: shadow[int]
#       ],
#       2: palettes [
#           [
#               [
#                   0: outlines[Color],
#                   1: colors[Color],
#                   2: hightlight[int],
#                   3: shadow[int]
#               ],
#           ],
#       ]
#   ]
# ]
# material_name: String = material[0]
# material_outlines: Array = material[1]
# material_outline_ids: Array = material[1][0]
# material_color_ids: Array = material[1][1]
# material_palettes: Array = material[2]
# cur_material_data: Array = material_data[selected_material_tab][2][cur_palette][selected_material]
# material_outlines: Array = cur_material_data[0]
# material_colors: Array = cur_material_data[1]

func get_pressed_material_button():
    return get_container().get_child(0).button_group.get_pressed_button()
