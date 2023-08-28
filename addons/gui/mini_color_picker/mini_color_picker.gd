@tool
@icon("./icon.png")
class_name MiniColorPicker
extends MarginContainer

signal color_changed(col: Color)

@export var color := Color.WHITE:
    set(value):
        color = value
        if wheel:
            wheel.color = value
            main_color_rect.update_color(value)
            hex_edit.text = value.to_html(true)
            emit_signal("color_changed", value)

var wheel
var main_color_rect
var hex_edit
var sliders_window


func _init(col := Color.WHITE):
    for m in ["left", "right", "top", "bottom"]:
        add_theme_constant_override("margin_%s" % m, 4)
    custom_minimum_size = Vector2i(192, 168)
    var vbox := VBoxContainer.new()
    add_child(vbox)
    color = col
    wheel = ColorWheel.new(col)
    vbox.add_child(wheel)
    var color_box = HBoxContainer.new()
    add_theme_constant_override("separation", 2)
    vbox.add_child(color_box)
    var panel_checker = PanelChecker.new()
    color_box.add_child(panel_checker, true)
    main_color_rect = BColor.new(col)
    main_color_rect.pressed.connect(_on_main_color_rect_pressed)
    panel_checker.add_child(main_color_rect, true)
    var switch_wheel_button := ToolButton.new()
    switch_wheel_button.icon = load("res://addons/gui/mini_color_picker/change.png")
    switch_wheel_button.flat = true
    switch_wheel_button.tooltip_text = "Change wheel shape"
    switch_wheel_button.pressed.connect(
            Callable(wheel, "_on_switch_wheel_pressed")
    )
    color_box.add_child(switch_wheel_button, true)
    wheel.color_changed.connect(_on_color_changed)
    var hex_box := HBoxContainer.new()
    hex_box.add_theme_constant_override("separation", 0)
    vbox.add_child(hex_box)
    hex_edit = HexEdit.new(col)
    hex_edit.text_submitted.connect(_on_hex_text_submitted)
    hex_box.add_child(hex_edit, true)
    var minus_button = ToolButton.new()
    minus_button.icon = load("res://addons/gui/mini_color_picker/subtract.png")
    minus_button.tooltip_text = "Decrease wheel height"
    minus_button.pressed.connect(
            Callable(wheel, "_on_resize_wheel_pressed").bind(-1)
    )
    hex_box.add_child(minus_button, true)
    var plus_button = ToolButton.new()
    plus_button.icon = load("res://addons/gui/mini_color_picker/add.png")
    plus_button.tooltip_text = "Increase wheel height"
    plus_button.pressed.connect(
            Callable(wheel, "_on_resize_wheel_pressed").bind(1)
    )
    hex_box.add_child(plus_button, true)
    sliders_window = SlidersWindow.new()
    sliders_window.about_to_popup.connect(_on_sliders_about_to_popup)
    vbox.add_child(sliders_window)
    sliders_window.sliders.color_changed.connect(_on_sliders_color_changed)


func _ready():
    if Engine.is_editor_hint():
        if owner:
            owner.get_viewport().size_changed.connect(
                    Callable(sliders_window, "_on_vp_resized")
            )
    else:
        get_tree().get_root().get_viewport().size_changed.connect(
                Callable(sliders_window, "_on_vp_resized")
        )


func _on_color_changed(col: Color):
    color = col


func _on_hex_text_submitted(new_text: String):
    if not new_text.is_valid_html_color():
        hex_edit.text = wheel.color.to_html(true)
        return
    var col = Color(new_text)
    emit_signal("color_changed", col)
    wheel.color = col
    main_color_rect.update_color(col)


func _on_main_color_rect_pressed():
    sliders_window.popup_centered()


func _on_sliders_about_to_popup():
    sliders_window.sliders.color = wheel.color
    sliders_window.panel_stylebox.bg_color = wheel.color
    sliders_window.switch_button.grab_focus()


func _on_sliders_color_changed(col: Color):
    sliders_window.panel_stylebox.bg_color = col
    wheel.color = col
    wheel.emit_signal("color_changed", col)


class ColorWheel:
    extends ColorPicker
    
    var wheel_size = 0
    
    func _init(col: Color):
        color = col
        color_mode = MODE_HSV
        picker_shape = SHAPE_OKHSL_CIRCLE
        can_add_swatches = false
        sampler_visible = false
        color_modes_visible = false
        sliders_visible = false
        hex_visible = false
        presets_visible = false
        add_theme_constant_override("sv_width", 68)
        add_theme_constant_override("sv_height", 72)
        add_theme_constant_override("h_width", 24)
    
    
    func _on_resize_wheel_pressed(i: int):
        var arr := [72, 128, 192]
        var new_size = clampi(wheel_size + i, 0, 2)
        if new_size == wheel_size:
            return
        wheel_size = new_size
        add_theme_constant_override("sv_height", arr[wheel_size])
    
    
    func _on_switch_wheel_pressed():
        var cur_wheel = int(picker_shape)
        cur_wheel = wrapi(cur_wheel + 1, 0, 4)
        match cur_wheel:
            0:
                picker_shape = SHAPE_HSV_RECTANGLE
            1:
                picker_shape = SHAPE_HSV_WHEEL
            2:
                picker_shape = SHAPE_VHS_CIRCLE
            3:
                picker_shape = SHAPE_OKHSL_CIRCLE


class PanelChecker:
    extends PanelContainer

    var checker_shader = preload("res://addons/gui/shaders/checker.gdshader")

    var draw_outlines := true:
        set(v):
            draw_outlines = v
            queue_redraw()


    func _ready():
        material = ShaderMaterial.new()
        material.shader = checker_shader
        resized.connect(_on_resized)
        update_size()
        size_flags_horizontal = SIZE_EXPAND_FILL
        var style = StyleBoxFlat.new()
        add_theme_stylebox_override("panel", style)
    
    
    func _on_resized():
        update_size()
    
    
    func update_size():
        material.set_shader_parameter("texture_size", size)
    
    
    func _draw():
        if draw_outlines:
            draw_rect(Rect2i(0, 0, floor(size.x), floor(size.y)), Color.WHITE, false, -1)


class BColor:
    extends ToolButton

    var normal_style = StyleBoxFlat.new()
    var focus_style = StyleBoxFlat.new()


    func _init(col: Color):
        normal_style.bg_color = col
        for s in ["normal", "hover", "pressed", "disabled"]:
            add_theme_stylebox_override(s, normal_style)
        focus_style.draw_center = false
        focus_style.set_border_width_all(2)
        focus_style.border_color = Color("42c2ff")
        focus_style.set_expand_margin_all(2)
        focus_style.anti_aliasing = false
        add_theme_stylebox_override("focus", focus_style)
    
    
    func update_color(col: Color):
        normal_style.bg_color = col


class HexEdit:
    extends LineEdit
    
    
    func _init(col: Color):
        text = col.to_html(true)
        placeholder_text = "#HEX"
        max_length = 8
        context_menu_enabled = false
        caret_blink = true
        caret_blink_interval = 0.5
        auto_translate = false
        localize_numeral_system = false
        size_flags_horizontal = SIZE_EXPAND_FILL


class SlidersWindow:
    extends Window
    
    var sliders
    var panel_stylebox
    var switch_button
    
    
    func _init():
        exclusive = true
        wrap_controls = true
        unresizable = true
        close_requested.connect(_on_close_requested)
        hide()
        title = "Color Edit"
        var margin = MarginContainer.new()
        for m in ["left", "right", "top", "bottom"]:
            margin.add_theme_constant_override("margin_%s" % m, 3)
        add_child(margin)
        margin.anchors_preset = Control.PRESET_FULL_RECT
        var sliders_vbox := VBoxContainer.new()
        sliders_vbox.add_theme_constant_override("separation", 8)
        margin.add_child(sliders_vbox, true)
        var sliders_hbox := HBoxContainer.new()
        sliders_hbox.add_theme_constant_override("separation", 4)
        sliders_hbox.size_flags_vertical = Control.SIZE_EXPAND_FILL
        sliders_vbox.add_child(sliders_hbox, true)
        sliders = ColorSliders.new()
        sliders_vbox.add_child(sliders, true)
        var panel_checker = PanelChecker.new()
        sliders_hbox.add_child(panel_checker, true)
        var color_panel = Panel.new()
        panel_stylebox = StyleBoxFlat.new()
        panel_stylebox.bg_color = Color.WHITE
        color_panel.add_theme_stylebox_override("panel", panel_stylebox)
        panel_checker.add_child(color_panel, true)
        switch_button = ToolButton.new()
        switch_button.icon = load("res://addons/gui/mini_color_picker/change.png")
        switch_button.pressed.connect(Callable(sliders, "_on_switch_pressed"))
        sliders_hbox.add_child(switch_button, true)
    
    
    func _input(ev: InputEvent):
        if not visible:
            return
        if ev.is_action_pressed("ui_cancel"):
            hide()
            get_viewport().set_input_as_handled()
    
    
    func _on_close_requested():
        hide()
    
    
    func _on_vp_resized():
        if not Engine.is_editor_hint():
            position = (get_viewport().size - size) / 2


class ColorSliders:
    extends ColorPicker
    
    
    func _init():
        get_child(0, true).get_child(0).get_child(0).hide()
        get_child(0, true).get_child(0).get_child(3).hide()
        color_mode = MODE_HSV
        picker_shape = SHAPE_NONE
        can_add_swatches = false
        sampler_visible = false
        color_modes_visible = false
        hex_visible = false
        presets_visible = false
        custom_minimum_size.x = 256
        add_theme_constant_override("label_width", 20)
    
    
    func _on_switch_pressed():
        var mode := [MODE_HSV, MODE_RGB, MODE_OKHSL, MODE_RAW]
        var cur = wrapi(mode.find(color_mode) + 1, 0, 4)
        color_mode = mode[cur]
