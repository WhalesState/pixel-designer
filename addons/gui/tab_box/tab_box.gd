@tool
@icon("./icon.png")
## A custom TabContainer that allows focusing tabs with keyboard!
class_name TabBox
extends VBoxContainer

## emits when [member tab] changes.
signal tab_changed(tab_ind: int)
signal tab_moved(from: int, to: int)

## Current container tab index.
@export var tab := -1:
    set(v):
        if tab_bar.get_child_count() == 0:
            tab = -1
            return
        tab = wrapi(v, 0, tab_bar.get_child_count())
        tab_bar.get_child(tab).button_pressed = true
        var cur_focus = get_viewport().gui_get_focus_owner()
        emit_signal("tab_changed", tab)


## Tab container top bar.
var tab_bar := HBoxContainer.new()
## Tab container.
var tab_container := TabContainer.new()
## Tabs button group. 
var tab_group := ButtonGroup.new()


func _init():
    add_theme_constant_override("separation", 0)
    tab_bar.add_theme_constant_override("separation", 2)
    
    var hbox := HBoxContainer.new()
    hbox.add_theme_constant_override("separation", 0)
    add_child(hbox)
    
    var scroll := ScrollContainer.new()
    scroll.follow_focus = true
    scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_SHOW_NEVER
    scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
    scroll.size_flags_horizontal = SIZE_EXPAND_FILL
    hbox.add_child(scroll)
    scroll.add_child(tab_bar)
    
    var left_button := ToolButton.new()
    left_button.text = "<"
    left_button.pressed.connect(_on_switch_tab.bind(-1))
    left_button.focus_mode = Control.FOCUS_NONE
    hbox.add_child(left_button)
    
    var right_button := ToolButton.new()
    right_button.text = ">"
    right_button.pressed.connect(_on_switch_tab.bind(1))
    right_button.focus_mode = Control.FOCUS_NONE
    hbox.add_child(right_button)
    
    tab_container.tabs_visible = false
    tab_container.anchors_preset = PRESET_FULL_RECT
    tab_container.size_flags_vertical = SIZE_EXPAND_FILL
    tab_container.size_flags_horizontal = SIZE_EXPAND_FILL
    add_child(tab_container)


func add_tab(tab_name: String, align_center := true) -> int:
    var button := TabButton.new(tab_name, tab_group)
    tab_bar.add_child(button)
    button.tab_moved.connect(_on_tab_moved)
    button.tab_pressed.connect(_on_tab_button_toggled)
    var scroll := ScrollContainer.new()
    scroll.anchors_preset = PRESET_FULL_RECT
    scroll.follow_focus = true
    scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
    scroll.size_flags_horizontal = SIZE_EXPAND_FILL
    scroll.size_flags_vertical = SIZE_EXPAND_FILL
    tab_container.add_child(scroll)
    var margin := MarginContainer.new()
    for m in ["left", "right", "top", "bottom"]:
        margin.add_theme_constant_override("margin_%s" % m, 4)
    margin.size_flags_horizontal = SIZE_EXPAND_FILL
    margin.size_flags_vertical = SIZE_EXPAND_FILL
    scroll.add_child(margin)
    var container := HFlowContainer.new()
    container.alignment = FlowContainer.ALIGNMENT_CENTER if align_center else FlowContainer.ALIGNMENT_BEGIN
    container.add_theme_constant_override("h_separation", 8)
    container.add_theme_constant_override("v_separation", 8)
    margin.add_child(container)
    if tab_bar.get_child_count() == 1:
        tab = 0
    return button.get_index()


## Returns the tab name.
func get_tab_name(ind: int) -> String:
    if ind > -1 and ind < tab_bar.get_child_count():
        return tab_bar.get_child(ind).text
    return ""


## Removes all tabs.
func clear() -> void:
    for child in tab_container.get_children():
        tab_container.remove_child(child)
        child.queue_free()
    for child in tab_bar.get_children():
        tab_bar.remove_child(child)
        child.queue_free()
    tab = -1


func _on_tab_button_toggled(ind: int) -> void:
    tab = ind
    tab_container.current_tab = tab


func _on_switch_tab(dir: int):
    tab += dir
    tab_bar.get_child(tab).grab_focus()


func _on_tab_moved(from: int, to: int):
    var button_from = tab_bar.get_child(from)
    var container_from = tab_container.get_child(from)
    tab_bar.move_child(button_from, to)
    tab_container.move_child(container_from, to)
    emit_signal("tab_moved", from, to)


## TabButton refers to [member TabBox.tab_bar] child buttons
class TabButton:
    extends Button
    
    signal tab_pressed(ind: int)
    signal tab_moved(from: int, to: int)
    
    
    func _init(_name: String, group: ButtonGroup):
        text = _name
        theme_type_variation = "TabButton"
        toggle_mode = true
        button_group = group
        toggled.connect(_on_toggled)
    
    
    func _on_toggled(is_pressed: bool) -> void:
        if is_pressed:
            emit_signal("tab_pressed", get_index())
    
    
    func _get_drag_data(_pos: Vector2):
        var prev = Button.new()
        prev.text = text
        set_drag_preview(prev)
        return self
    
    
    func _can_drop_data(_pos, data):
        if data.button_group == button_group and data != self:
            return true
        return false
    
    
    func _drop_data(_pos, data):
        emit_signal("tab_moved", data.get_index(), get_index())
