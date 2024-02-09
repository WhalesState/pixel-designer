@tool
@icon("./icon.png")
class_name MiniColorPicker
extends MarginContainer

## Emits when color changes.
signal color_changed(col: Color)

## picker color.
@export var color := Color.WHITE:
    set(value):
        color = value
        if wheel:
            wheel.color = value
            main_color_rect.update_color(value)
            hex_edit.text = value.to_html(true)
            emit_signal("color_changed", value)

## Picker wheel.
var wheel
## Color rect button.
var main_color_rect
## Hex line edit.
var hex_edit
## Sliders popup window.
var sliders_window


func _init(col := Color.WHITE):
    for m in ["left", "right", "bottom"]:
        add_theme_constant_override("margin_%s" % m, 4)
    custom_minimum_size = Vector2i(128, 128)
    # Main VBox.
    var vbox := VBoxContainer.new()
    vbox.add_theme_constant_override("separation", 4)
    add_child(vbox)
    # Color wheel.
    color = col
    wheel = ColorWheel.new(col)
    vbox.add_child(wheel)
    # Color HBox.
    var color_box = HBoxContainer.new()
    vbox.add_child(color_box)
    # Hex edit.
    hex_edit = HexEdit.new(col)
    hex_edit.text_submitted.connect(_on_hex_text_submitted)
    color_box.add_child(hex_edit, true)
    # Color panel.
    var panel_checker = PanelChecker.new()
    panel_checker.custom_minimum_size = Vector2i(32, 0)
    color_box.add_child(panel_checker, true)
    main_color_rect = BColor.new(col)
    main_color_rect.pressed.connect(_on_main_color_rect_pressed)
    panel_checker.add_child(main_color_rect, true)
    # Wheel switch button.
    var switch_wheel_button := ToolButton.new()
    switch_wheel_button.icon = load("res://addons/gui/mini_color_picker/change.png")
    switch_wheel_button.flat = true
    switch_wheel_button.tooltip_text = "Change wheel shape"
    switch_wheel_button.pressed.connect(wheel._on_switch_wheel_pressed)
    color_box.add_child(switch_wheel_button, true)
    wheel.color_changed.connect(_on_color_changed)
    # Sliders Popup.
    sliders_window = SlidersWindow.new()
    sliders_window.about_to_popup.connect(_on_sliders_about_to_popup)
    vbox.add_child(sliders_window)
    sliders_window.sliders.color_changed.connect(_on_sliders_color_changed)


## Color Changed.
func _on_color_changed(col: Color):
    color = col


## Hex line edit text submitted.
func _on_hex_text_submitted(new_text: String):
    if not new_text.is_valid_html_color():
        hex_edit.text = wheel.color.to_html(true)
        return
    var col = Color(new_text)
    emit_signal("color_changed", col)
    wheel.color = col
    main_color_rect.update_color(col)


## Color rect pressed.
func _on_main_color_rect_pressed():
    if sliders_window.last_pos.x > 0 and sliders_window.last_pos.y > 0:
        sliders_window.popup(Rect2i(sliders_window.last_pos, Vector2i(320, 0)))
    else:
        sliders_window.popup_centered_clamped(Vector2i(320, 0))


## Sliders popup about to popup.
func _on_sliders_about_to_popup():
    sliders_window.sliders.color = wheel.color
    sliders_window.panel_stylebox.bg_color = wheel.color
    sliders_window.switch_button.grab_focus()


## Sliders color changed.
func _on_sliders_color_changed(col: Color):
    sliders_window.panel_stylebox.bg_color = col
    wheel.color = col
    wheel.emit_signal("color_changed", col)


## Color wheel class.
class ColorWheel:
    extends ColorPicker
    
    func _init(col: Color):
        color = col
        color_mode = MODE_HSV
        picker_shape = SHAPE_OKHSL_CIRCLE
        can_add_swatches = false
        sampler_visible = false
        sliders_visible = false
        hex_visible = false
        presets_visible = false
        add_theme_constant_override("sv_width", 68)
        add_theme_constant_override("sv_height", 72)
        add_theme_constant_override("h_width", 24)
        size_flags_vertical = SIZE_EXPAND_FILL
        # get_child(0, true).size_flags_vertical = SIZE_EXPAND_FILL
        # get_child(0, true).get_child(0).size_flags_vertical = SIZE_EXPAND_FILL
        # get_child(0, true).get_child(0).get_child(0).size_flags_vertical = SIZE_EXPAND_FILL
    
    ## Switch color wheel shape.
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


## Panel checker class.
class PanelChecker:
    extends PanelContainer
    
    ## Checker shader.
    var checker_shader = preload("res://addons/gui/shaders/checker.gdshader")


    func _ready():
        material = ShaderMaterial.new()
        material.shader = checker_shader
        material.set_shader_parameter("size", Vector2i(8, 8))
        resized.connect(_on_resized)
        update_size()
        size_flags_horizontal = SIZE_EXPAND_FILL
        var style = StyleBoxFlat.new()
        add_theme_stylebox_override("panel", style)
    
    ## on node resized.
    func _on_resized():
        update_size()
    
    ## Update checker texture size.
    func update_size():
        material.set_shader_parameter("texture_size", size)


## Color button class.
class BColor:
    extends ToolButton
    
    ## Normal stylebox.
    var normal_style = StyleBoxFlat.new()
    ## Focus stylebox.
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
    
    ## Update button's color.
    func update_color(col: Color):
        normal_style.bg_color = col


## Hex line edit.
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


## Sliders popup window.
class SlidersWindow:
    extends Window
    
    ## Color sliders.
    var sliders: ColorSliders
    ## Panel stylebox.
    var panel_stylebox: StyleBoxFlat
    ## Sliders switch button.
    var switch_button: ToolButton
    ## Popup window last position.
    var last_pos := -Vector2i.ONE
    
    
    func _init():
        exclusive = true
        wrap_controls = true
        transient = true
        unresizable = false
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
        switch_button.pressed.connect(sliders._on_switch_pressed)
        sliders_hbox.add_child(switch_button, true)
    
    
    func _input(ev: InputEvent):
        if not visible:
            return
        if ev.is_action_pressed("ui_cancel"):
            last_pos = position
            hide()
            get_viewport().set_input_as_handled()
    
    
    ## On popup close request.
    func _on_close_requested():
        last_pos = position
        hide()


## Color picker sliders.
class ColorSliders:
    extends ColorPicker
    
    
    func _init():
        # get_child(0, true).get_child(0).get_child(0).hide()
        # get_child(0, true).get_child(0).get_child(2).hide()
        wheel_visible = false
        sampler_visible = false
        color_mode = MODE_HSV
        can_add_swatches = false
        sampler_visible = false
        hex_visible = false
        presets_visible = false
        custom_minimum_size.x = 256
        add_theme_constant_override("label_width", 20)
    
    
    ## On switch slider button pressed.
    func _on_switch_pressed():
        var mode := [MODE_HSV, MODE_RGB, MODE_OKHSL, MODE_RAW]
        var cur = wrapi(mode.find(color_mode) + 1, 0, mode.size())
        color_mode = mode[cur]
