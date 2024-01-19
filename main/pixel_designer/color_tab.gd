@tool
extends TabBox

signal color_button_pressed(col: Color)


func _ready():
    for s in ["Outlines", "Colors", "Highlight", "Shadow"]:
        add_tab(s, false, false, false, false)
    var col
    var group := ButtonGroup.new()
    for i in range(2):
        col = create_color_button(true if i == 0 else false)
        col.button.button_group = group
        get_container(0).add_child(col)
    group = ButtonGroup.new()
    for i in range(6):
        col = create_color_button(true if i == 0 else false)
        col.button.button_group = group
        get_container(1).add_child(col)
    group = ButtonGroup.new()
    col = create_color_button(true)
    col.button.button_group = group
    get_container(2).add_child(col)
    group = ButtonGroup.new()
    col = create_color_button(true)
    col.button.button_group = group
    get_container(3).add_child(col)


func create_color_button(_pressed := false) -> MiniColorButton:
    var color_button := MiniColorButton.new()
    color_button.pressed.connect(_on_color_button_pressed)
    color_button.button.toggle_mode = true
    if _pressed:
        color_button.button.button_pressed = true
    color_button.size_flags_horizontal = SIZE_EXPAND_FILL
    return color_button


func _on_color_button_pressed(col: Color):
    emit_signal("color_button_pressed", col)
