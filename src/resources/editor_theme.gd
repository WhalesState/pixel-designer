class_name EditorTheme
extends Theme

signal colors_changed
signal icons_changed

const DEFAULT_FONT = preload("res://theme/fonts/NotoSans_Regular.woff2")

enum FontColorOverride {
	AUTO,
	LIGHT,
	DARK,
	CUSTOM,
}

var first_load = true
var updating = false
var updating_icons = false

@export_color_no_alpha var primary_color: Color:
	set(value):
		value.a = 1.0
		if primary_color != value:
			primary_color = value
			_dark_theme = primary_color.get_luminance() <= 0.5
			if not first_load:
				Settings.get_singleton().set_value("theme", "primary_color", primary_color)
			button_pressed_style.bg_color = primary_color
			menu_button_pressed_style.bg_color = primary_color
			_update_font_color()
			update_theme()

@export_color_no_alpha var secondary_color: Color:
	set(value):
		value.a = 1.0
		if secondary_color != value:
			secondary_color = value
			if not first_load:
				Settings.get_singleton().set_value("theme", "secondary_color", secondary_color)
			popup_panel_style.border_color = secondary_color
			tab_selected_style.border_color = secondary_color
			tab_focus_style.border_color = secondary_color
			button_focus_style.bg_color = secondary_color
			button_focus_style.border_color = secondary_color
			menu_button_focus_style.bg_color = secondary_color
			menu_button_focus_style.border_color = secondary_color
			progress_fill_style.bg_color = secondary_color
			grabber_highlight_style.bg_color = secondary_color
			set_color("icon_pressed_color", "Button", secondary_color)
			set_color("icon_hover_pressed_color", "Button", secondary_color)
			set_color("font_pressed_color", "Button", secondary_color)
			set_color("font_hover_pressed_color", "Button", secondary_color)
			set_color("grabber_pressed", "SplitContainer", secondary_color)
			set_color("clear_button_color_pressed", "LineEdit", secondary_color)
			update_theme()

@export_range(-1.0, 1.0, 0.01) var contrast: float:
	set(value):
		value = clampf(value, -1.0, 1.0)
		if value != contrast:
			contrast = value
			if not first_load:
				Settings.get_singleton().set_value("theme", "contrast", contrast)
			update_theme()

@export_range(0, 6, 1) var margin: int:
	set(value):
		value = clampi(value, 0, 6)
		if value != margin:
			margin = value
			if not first_load:
				Settings.get_singleton().set_value("theme", "margin", margin)
			_int_margin = round(margin * editor_scale)

@export_range(0, 6) var padding: int:
	set(value):
		value = clampi(value, 0, 6)
		if value != padding:
			padding = value
			if not first_load:
				Settings.get_singleton().set_value("theme", "padding", padding)
			_int_border_padding = round((border_width + padding) * editor_scale)
			_int_padding = round(padding * editor_scale)

@export_range(0, 4) var border_width: int:
	set(value):
		value = clampi(value, 0, 4)
		if value != border_width:
			border_width = value
			if not first_load:
				Settings.get_singleton().set_value("theme", "border_width", border_width)
			_int_border_width = round(border_width * editor_scale)
			_int_border_padding = round((border_width + padding) * editor_scale)

@export_range(0, 8) var corner_radius: int:
	set(value):
		value = clampi(value, 0, 8)
		if value != corner_radius:
			corner_radius = value
			if not first_load:
				Settings.get_singleton().set_value("theme", "corner_radius", corner_radius)
			_int_corners = round(corner_radius * editor_scale)

# TODO:
@export_range(0, 2) var font_outline: int:
	set(value):
		if value != font_outline:
			font_outline = value
			if not first_load:
				Settings.get_singleton().set_value("theme", "font_outline", font_outline)


@export_range(1, 4, 0.1) var editor_scale: float:
	set(value):
		value = clamp(value, 1, 4)
		if value != editor_scale:
			editor_scale = value
			if not first_load:
				Settings.get_singleton().set_value("theme", "editor_scale", editor_scale)
			_int_corners = round(corner_radius * editor_scale)
			_int_border_width = round(border_width * editor_scale)
			_int_border_padding = round((border_width + padding) * editor_scale)
			_int_padding = round(padding * editor_scale)
			_int_margin = round(margin * editor_scale)
			var int_editor_scale: int = round(editor_scale)
			var int_1x_border: int = round(2 * editor_scale)
			var int_2x_border: int = round(4 * editor_scale)
			var int_3x_border: int = round(6 * editor_scale)
			tab_selected_style.border_width_top = int_1x_border
			tab_selected_style.content_margin_top = int_1x_border
			tab_unselected_style.content_margin_top = int_1x_border
			tab_disabled_style.content_margin_top = int_1x_border
			tab_focus_style.set_border_width_all(int_1x_border)
			h_separator_style.thickness = int_1x_border
			v_separator_style.thickness = int_1x_border
			grabber_style.set_content_margin_all(int_2x_border)
			slider_style.set_content_margin_all(int_1x_border)
			h_scroll_style.content_margin_top = int_2x_border
			h_scroll_style.content_margin_bottom = int_2x_border
			v_scroll_style.content_margin_left = int_2x_border
			v_scroll_style.content_margin_right = int_2x_border
			set_constant("icon_separation", "TabContainer", int_1x_border)
			if not ColorButton.checker_style:
				ColorButton.checker_style = CheckerStyleBox.new()
			ColorButton.checker_style.scale = int_editor_scale
			ColorButton.checker_style.set_content_margin_all(int_1x_border)
			if not ColorButton.focus_style:
				ColorButton.focus_style = StyleBoxFlat.new()
			ColorButton.focus_style.draw_center = false
			ColorButton.focus_style.set_border_width_all(int_1x_border)
			set_constant("grabber_thickness", "SplitContainer", int_2x_border)
			set_constant("minimum_grab_thickness", "SplitContainer", int_3x_border)
			set_constant("separation", "SplitContainer", int_3x_border)
			set_constant("caret_width", "LineEdit", int_editor_scale)
			set_constant("caret_width", "TextEdit", int_editor_scale)
			set_constant("line_spacing", "TextEdit", int_2x_border)
			set_constant("h_separation", "PopupMenu", int_2x_border)
			set_constant("v_separation", "PopupMenu", int_2x_border)
			set_constant("item_margin", "Tree", round(16 * editor_scale))
			set_constant("parent_hl_line_width", "Tree", int_1x_border)
			set_constant("relationship_line_width", "Tree", round(editor_scale))
			set_constant("v_separation", "Tree", int_2x_border)
			MessageQueue.get_singleton().queue_call(_update_icons)

@export_range(0.0, 1.0) var primary_color2_value:
	set(value):
		value = clampf(value, 0.0, 1.0)
		if value != primary_color2_value:
			primary_color2_value = value
			if not first_load:
				Settings.get_singleton().set_value("theme", "primary_color2_value", primary_color2_value)
			update_theme()

@export_range(0.0, 1.0) var primary_color3_value: float:
	set(value):
		value = clampf(value, 0.0, 1.0)
		if value != primary_color3_value:
			primary_color3_value = value
			if not first_load:
				Settings.get_singleton().set_value("theme", "primary_color3_value", primary_color3_value)
			update_theme()

@export_range(0.0, 1.0) var primary_color4_value: float:
	set(value):
		value = clampf(value, 0.0, 1.0)
		if value != primary_color4_value:
			primary_color4_value = value
			if not first_load:
				Settings.get_singleton().set_value("theme", "primary_color4_value", primary_color4_value)
			update_theme()

@export_range(0.0, 1.0) var secondary_color2_value: float:
	set(value):
		value = clampf(value, 0.0, 1.0)
		if value != secondary_color2_value:
			secondary_color2_value = value
			if not first_load:
				Settings.get_singleton().set_value("theme", "secondary_color2_value", secondary_color2_value)
			update_theme()

@export_range(0.0, 1.0) var bg_color_value: float:
	set(value):
		value = clampf(value, 0.0, 1.0)
		if value != bg_color_value:
			bg_color_value = value
			if not first_load:
				Settings.get_singleton().set_value("theme", "bg_color_value", bg_color_value)
			update_theme()

@export_global_file("*.ttf", "*.otf", "*.woff2") var custom_font: String:
	set(value):
		if value != custom_font:
			custom_font = value
			if not first_load:
				Settings.get_singleton().set_value("theme", "custom_font", custom_font)
			update_custom_font()

@export var font_color_override: FontColorOverride:
	set(value):
		value = clamp(value, 0, 3)
		if value != font_color_override:
			var notify := false
			if font_color_override == FontColorOverride.CUSTOM || value == FontColorOverride.CUSTOM:
				notify = true
			font_color_override = value
			if not first_load:
				Settings.get_singleton().set_value("theme", "font_color_override", font_color_override)
			_update_font_color()
			if notify:
				notify_property_list_changed()

@export_color_no_alpha var custom_font_color: Color:
	set(value):
		value.a = 1.0
		if value != custom_font_color:
			custom_font_color = value
			if not first_load:
				Settings.get_singleton().set_value("theme", "custom_font_color", custom_font_color)
			if font_color_override == FontColorOverride.CUSTOM:
				_update_font_color()

@export_range(-2.0, 2.0) var font_embolden: float:
	set(value):
		value = clampf(value, -2.0, 2.0)
		if value != font_embolden:
			font_embolden = value
			if not first_load:
				Settings.get_singleton().set_value("theme", "font_embolden", font_embolden)
			default_font.variation_embolden = font_embolden

@export_range(-16, 16) var font_spacing_glyph: int:
	set(value):
		value = clampi(value, -16, 16)
		if value != font_spacing_glyph:
			font_spacing_glyph = value
			if not first_load:
				Settings.get_singleton().set_value("theme", "font_spacing_glyph", font_spacing_glyph)
			default_font.spacing_glyph = font_spacing_glyph

@export_range(-16, 16) var font_spacing_space: int:
	set(value):
		value = clampi(value, -16, 16)
		if value != font_spacing_space:
			font_spacing_space = value
			if not first_load:
				Settings.get_singleton().set_value("theme", "font_spacing_space", font_spacing_space)
			default_font.spacing_space = font_spacing_space

@export_range(-16, 16) var font_spacing_top: int:
	set(value):
		value = clampi(value, -16, 16)
		if value != font_spacing_top:
			font_spacing_top = value
			if not first_load:
				Settings.get_singleton().set_value("theme", "font_spacing_top", font_spacing_top)
			default_font.spacing_top = font_spacing_top

@export_range(-16, 16) var font_spacing_bottom: int:
	set(value):
		value = clampi(value, -16, 16)
		if value != font_spacing_bottom:
			font_spacing_bottom = value
			if not first_load:
				Settings.get_singleton().set_value("theme", "font_spacing_bottom", font_spacing_bottom)
			default_font.spacing_bottom = font_spacing_bottom

@export_range(8, 32) var font_size: int:
	set(value):
		value = clampi(value, 8, 32)
		if value != font_size:
			font_size = value
			if not first_load:
				Settings.get_singleton().set_value("theme", "font_size", font_size)
			default_font_size = font_size

var _font_color: Color:
	set(color):
		if color != _font_color:
			_font_color = color
			panel_style.border_color = color
			h_separator_style.color = color
			v_separator_style.color = color
			set_color("font_hovered_color", "TabContainer", color)
			set_color("drop_mark_color", "TabContainer", color)
			set_color("font_hover_color", "PopupMenu", color)
			set_color("font_selected_color", "LineEdit", color)
			set_color("font_selected_color", "TextEdit", color)
			set_color("caret_background_color", "TextEdit", color)
			set_color("font_color", "ProgressBar", color)
			set_color("hover_font_color", "FoldableContainer", color)
			set_color("font_hover_color", "Button", color)
			set_color("icon_hover_color", "Button", color)
			ColorButton.focus_style.border_color = color
			color.a = 0.9
			set_color("font_selected_color", "TabContainer", color)
			set_color("icon_focus_color", "Button", color)
			set_color("font_focus_color", "Button", color)
			color.a = 0.8
			set_color("icon_normal_color", "Button", color)
			set_color("font_color", "Button", color)
			set_color("grabber_hovered", "SplitContainer", color)
			set_color("font_color", "Label", color)
			set_color("font_color", "LineEdit", color)
			set_color("font_color", "TextEdit", color)
			set_color("caret_color", "LineEdit", color)
			set_color("caret_color", "TextEdit", color)
			set_color("clear_button_color", "LineEdit", color)
			set_color("font_color", "PopupMenu", color)
			set_color("font_color", "FoldableContainer", color)
			set_color("font_unselected_color", "TabContainer", color)
			set_color("collapsed_font_color", "FoldableContainer", color)
			color.a = 0.6
			grabber_style.bg_color = color
			set_color("font_separator_color", "PopupMenu", color)
			set_color("font_accelerator_color", "PopupMenu", color)
			set_color("font_disabled_color", "PopupMenu", color)
			set_color("grabber_normal", "SplitContainer", color)
			set_color("font_uneditable_color", "LineEdit", color)
			set_color("font_readonly_color", "TextEdit", color)
			set_color("font_placeholder_color", "LineEdit", color)
			set_color("font_placeholder_color", "TextEdit", color)
			color.a = 0.4
			set_color("font_disabled_color", "TabContainer", color)
			set_color("icon_disabled_color", "Button", color)
			set_color("font_disabled_color", "Button", color)
			MessageQueue.get_singleton().queue_call(_update_icons)

var _int_corners: int:
	set(value):
		_int_corners = value
		MessageQueue.get_singleton().queue_call(_update_corners)

var _int_border_width: int:
	set(value):
		_int_border_width = value
		MessageQueue.get_singleton().queue_call(_update_border_width)

var _int_border_padding: int:
	set(value):
		if value != _int_border_padding:
			_int_border_padding = value
			MessageQueue.get_singleton().queue_call(_update_border_padding)

var _int_padding: int:
	set(value):
		if value != _int_padding:
			_int_padding = value
			MessageQueue.get_singleton().queue_call(_update_padding)

var _int_margin: int:
	set(value):
		if value != _int_margin:
			_int_margin = value
			MessageQueue.get_singleton().queue_call(_update_margin)

var _bg_color: Color
var _contrasted_color: Color
var _primary_color2: Color
var _primary_color3: Color
var _primary_color4: Color
var _secondary_color2: Color

var _dark_theme := false

var _icons := {}

var _icon_queue := []

## For "panel" in [Panel, PanelContainer, TabContainer].
var panel_style := StyleBoxFlat.new()
## For "panel" in [PopupMenu].
var popup_panel_style := StyleBoxFlat.new()
## For "panel" in [TabContainer].
var tab_panel_style := StyleBoxFlat.new()
## For "tab_selected" in [TabContainer].
var tab_selected_style := StyleBoxFlat.new()
## For "tab_unselectd" and "tab_hovered" in [TabContainer].
var tab_unselected_style := StyleBoxFlat.new()
## For "tab_disabled" in [TabContainer].
var tab_disabled_style := StyleBoxFlat.new()
## For "tab_focus" in [TabContainer].
var tab_focus_style := StyleBoxFlat.new()
## For "normal" in [Button].
var button_normal_style := StyleBoxFlat.new()
## For "hover" in [Button].
var button_hover_style := StyleBoxFlat.new()
## For "pressed" in [Button].
var button_pressed_style := StyleBoxFlat.new()
## For "disabled" in [Button].
var button_disabled_style := StyleBoxFlat.new()
## For "focus" in [Button].
var button_focus_style := StyleBoxFlat.new()
## For "normal" in [MenuButton].
var menu_button_normal_style := StyleBoxFlat.new()
## For "hover" in [MenuButton].
var menu_button_hover_style := StyleBoxFlat.new()
## For "pressed" in [MenuButton].
var menu_button_pressed_style := StyleBoxFlat.new()
## For "disabled" in [MenuButton].
var menu_button_disabled_style := StyleBoxFlat.new()
## For "focus" in [MenuButton].
var menu_button_focus_style := StyleBoxFlat.new()
## For "hover" in [PopupMenu].
var popup_hover_style := StyleBoxFlat.new()
## For "background" in [ProgressBar].
var progress_background_style := StyleBoxFlat.new()
## For "fill" in [ProgressBar].
var progress_fill_style := StyleBoxFlat.new()
## For "grabber_area" in [HSlider] and [VSlider].
var grabber_style := StyleBoxFlat.new()
## For "grabber_area_highlight" in [HSlider] and [VSlider].
var grabber_highlight_style := StyleBoxFlat.new()
## For "slider" in [HSlider] and [VSlider].
var slider_style := StyleBoxFlat.new()
## For "scroll" in [HScrollBar].
var h_scroll_style := StyleBoxFlat.new()
## For "scroll" in [VScrollBar].
var v_scroll_style := StyleBoxFlat.new()
## For "panel" in [FoldableContainer].
var foldable_panel_style := StyleBoxFlat.new()
## For "title_panel" in [FoldableContainer].
var foldable_title_style := StyleBoxFlat.new()
## For "title_collapsed_panel" in [FoldableContainer].
var foldable_title_collapsed_style := StyleBoxFlat.new()
## For "title_hover_panel" in [FoldableContainer].
var foldable_title_hover_style := StyleBoxFlat.new()
## For "title_collapsed_hover_panel" in [FoldableContainer].
var foldable_title_collapsed_hover_style := StyleBoxFlat.new()
## For separators in [PopupMenu] and [HSeparator].
var h_separator_style := StyleBoxLine.new()
## For "separator" in [VSeparator].
var v_separator_style := StyleBoxLine.new()

## [b]PRIVATE[/b] used for unique classes to easily access them with `ClassName.get_singleton()` from any other script.
static var _singleton: EditorTheme


func add_to_icon_queue(node: Node, property_name: String, icon_name: String):
	_icon_queue.append([node, property_name, icon_name])


func remove_from_icon_queue(node: Node, property_name: String, icon_name: String):
	_icon_queue.erase([node, property_name, icon_name])


func contrast_color(color: Color, value: float) -> Color:
	if is_equal_approx(value, 0):
		return color
	elif value > 0.0:
		return color.lightened(value)
	else:
		return color.darkened(value * -1)


func update_theme():
	MessageQueue.get_singleton().queue_call(_update_theme)


func _update_theme():
	# Keep deferring the call until the theme finish updating.
	if updating:
		MessageQueue.get_singleton().queue_call(_update_theme)
		return
	updating = true
	var time := Time.get_ticks_msec()
	# Set colors.
	_contrasted_color = contrast_color(primary_color, contrast)
	_primary_color2 = primary_color.lerp(_contrasted_color, primary_color2_value)
	_primary_color3 = primary_color.lerp(_contrasted_color, primary_color3_value)
	_primary_color4 = primary_color.lerp(_contrasted_color, primary_color4_value)
	_secondary_color2 = secondary_color.lerp(primary_color, secondary_color2_value)
	_bg_color = primary_color.lerp(_contrasted_color, bg_color_value)
	colors_changed.emit()
	set_color("selection_color", "LineEdit", _secondary_color2)
	set_color("selection_color", "TextEdit", _secondary_color2)
	popup_panel_style.bg_color = _bg_color
	button_hover_style.bg_color = _primary_color2
	menu_button_hover_style.bg_color = _primary_color2
	slider_style.bg_color = _primary_color2
	foldable_title_hover_style.bg_color = _primary_color2
	foldable_title_collapsed_hover_style.bg_color = _primary_color2
	panel_style.bg_color = _primary_color3
	tab_panel_style.bg_color = _primary_color3
	tab_selected_style.bg_color = _primary_color3
	popup_hover_style.bg_color = _primary_color3
	progress_background_style.bg_color = _primary_color3
	foldable_panel_style.bg_color = _primary_color3
	tab_unselected_style.bg_color = _primary_color4
	tab_disabled_style.bg_color = _primary_color4
	button_normal_style.bg_color = _primary_color4
	button_disabled_style.bg_color = _primary_color4
	menu_button_normal_style.bg_color = _primary_color4
	menu_button_disabled_style.bg_color = _primary_color4
	h_scroll_style.bg_color = _primary_color4
	v_scroll_style.bg_color = _primary_color4
	foldable_title_style.bg_color = _primary_color4
	foldable_title_collapsed_style.bg_color = _primary_color4
	tab_disabled_style.bg_color.a = 0.4
	button_disabled_style.bg_color.a = 0.4
	menu_button_disabled_style.bg_color.a = 0.4
	MessageQueue.get_singleton().queue_call(_update_icons)
	await icons_changed
	updating = false
	print_verbose("update theme: %s" % (Time.get_ticks_msec() - time))
	if first_load:
		first_load = false


func _update_font_color() -> void:
	if font_color_override == FontColorOverride.AUTO:
		_font_color = Color(0.9, 0.9, 0.9) if _dark_theme else Color(0.1, 0.1, 0.1)
	elif font_color_override == FontColorOverride.LIGHT:
		_font_color = Color(0.9, 0.9, 0.9)
	elif font_color_override == FontColorOverride.DARK:
		_font_color = Color(0.1, 0.1, 0.1)
	else:
		_font_color = custom_font_color


# Icons:
#    (1, 1, 1) = _font_color                     (white)
#    (1, 0, 0) = primary_color                  (red)
#    (0, 1, 0) = secondary_color                (green)
#    (0, 0, 1) = _primary_color2 contrasted      (blue)
#    (1, 1, 0) = _primary_color3 contrasted      (yellow)
#    (1, 0, 1) = _primary_color4 contrasted      (magneta)
#    (0, 1, 1) = _secondary_color2 lerp primary  (cyan)
#    (0, 0, 0) = _bg_color                       (black)
func _update_icons() -> void:
	if updating_icons:
		MessageQueue.get_singleton().queue_call(_update_icons)
		return
	updating_icons = true
	var time = Time.get_ticks_msec()
	var main := Main.get_singleton()
	for pixel_icon in _icons.keys():
		var svg: String = _icons[pixel_icon]
		var atr = svg.left(32)
		var convert_colors = atr.findn("no-convert") == -1
		var scale = atr.findn("no-scale") == -1
		if convert_colors:
			svg = svg.replace("\"#fff\"", "\"#%s\"" % _font_color.to_html(false))
			svg = svg.replace("\"#f00\"", "\"#%s\"" % primary_color.to_html(false))
			svg = svg.replace("\"#0f0\"", "\"#%s\"" % secondary_color.to_html(false))
			svg = svg.replace("\"#00f\"", "\"#%s\"" % _primary_color2.to_html(false))
			svg = svg.replace("\"#ff0\"", "\"#%s\"" % _primary_color3.to_html(false))
			svg = svg.replace("\"#f0f\"", "\"#%s\"" % _primary_color4.to_html(false))
			svg = svg.replace("\"#0ff\"", "\"#%s\"" % _secondary_color2.to_html(false))
			svg = svg.replace("\"#000\"", "\"#%s\"" % _bg_color.to_html(false))
		var img := Image.new()
		img.load_svg_from_string(svg, editor_scale if scale else 1.0)
		var _icon: ImageTexture
		if has_icon(pixel_icon, "icons"):
			_icon = get_icon(pixel_icon, "icons")
		if _icon and Vector2i(_icon.get_size()) == img.get_size():
			_icon.update(img)
		else:
			set_icon(pixel_icon, "icons", ImageTexture.create_from_image(img))
		await main.process_frame
	# [OptionButton].
	set_icon("arrow", "OptionButton", icon("Down"))
	# [CheckButton].
	set_icon("checked", "CheckButton", icon("CheckButtonChecked"))
	set_icon("checked_mirrored", "CheckButton", icon("CheckButtonCheckedMirrored"))
	set_icon("unchecked", "CheckButton", icon("CheckButtonUnchecked"))
	set_icon("unchecked_mirrored", "CheckButton", icon("CheckButtonUncheckedMirrored"))
	set_icon("checked_disabled", "CheckButton", icon("CheckButtonCheckedDisabled"))
	set_icon("checked_disabled_mirrored", "CheckButton", icon("CheckButtonCheckedDisabledMirrored"))
	# [CheckBox] and [PopupMenu].
	for type in ["CheckBox", "PopupMenu"]:
		set_icon("checked", type, icon("CheckBoxChecked"))
		set_icon("checked_disabled", type, icon("CheckBoxCheckedDisabled"))
		set_icon("unchecked", type, icon("CheckBoxUnchecked"))
		set_icon("unchecked_disabled", type, icon("CheckBoxUncheckedDisabled"))
		set_icon("radio_checked", type, icon("RadioChecked"))
		set_icon("radio_checked_disabled", type, icon("RadioCheckedDisabled"))
		set_icon("radio_unchecked", type, icon("RadioUnchecked"))
		set_icon("radio_unchecked_disabled", type, icon("RadioUncheckedDisabled"))
	# [PopupMenu]
	set_icon("submenu", "PopupMenu", icon("ArrowRight"))
	set_icon("submenu_mirrored", "PopupMenu", icon("ArrowLeft"))
	# [VSlider].
	set_icon("grabber", "VSlider", icon("Grabber"))
	set_icon("grabber_disabled", "VSlider", icon("GrabberDisabled"))
	set_icon("grabber_highlight", "VSlider", icon("GrabberHighlight"))
	# [HSlider].
	set_icon("grabber", "HSlider", icon("Grabber"))
	set_icon("grabber_disabled", "HSlider", icon("GrabberDisabled"))
	set_icon("grabber_highlight", "HSlider", icon("GrabberHighlight"))
	# [FoldableContainer].
	set_icon("arrow", "FoldableContainer", icon("Down"))
	set_icon("arrow_collapsed", "FoldableContainer", icon("Right"))
	set_icon("arrow_collapsed_mirrored", "FoldableContainer", icon("Left"))
	# [LineEdit].
	set_icon("clear", "LineEdit", icon("Clear"))
	# [SpinBox].
	for n in ["", "_disabled", "_hover", "_pressed"]:
		set_icon("up" + n, "SpinBox", icon("SpinBoxUp"))
		set_icon("down" + n, "SpinBox", icon("SpinBoxDown"))
	# [Tree].
	set_icon("arrow", "Tree", icon("Down"))
	set_icon("arrow_collapsed", "Tree", icon("Right"))
	set_icon("arrow_collapsed_mirrored", "Tree", icon("Left"))
	set_icon("checked", "Tree", icon("CheckBoxChecked"))
	set_icon("checked_disapled", "Tree", icon("CheckBoxCheckedDisabled"))
	set_icon("select_arrow", "Tree", icon("Down"))
	set_icon("unchecked", "Tree", icon("CheckBoxUnchecked"))
	set_icon("unchecked_disapled", "Tree", icon("CheckBoxUncheckedDisabled"))
	set_icon("updown", "Tree", icon("SpinBoxUpDown"))
	# [ColorPicker]
	set_icon("overbright_indicator", "ColorPicker", icon("OverBright"))
	set_icon("sample_bg", "ColorPicker", icon("Checker"))
	set_icon("sample_revert", "ColorPicker", icon("Reset"))
	set_icon("screen_picker", "ColorPicker", icon("Picker"))
	set_icon("shape_circle", "ColorPicker", icon("PickerCircle"))
	set_icon("shape_rect", "ColorPicker", icon("PickerRect"))
	set_icon("shape_rect_wheel", "ColorPicker", icon("PickerWheel"))
	# [TabContainer]
	set_icon("decrement", "TabContainer", icon("ScrollLeftDisabled"))
	set_icon("decrement_highlight", "TabContainer", icon("ScrollLeft"))
	set_icon("increment", "TabContainer", icon("ScrollRightDisabled"))
	set_icon("increment_highlight", "TabContainer", icon("ScrollRight"))
	# Queue
	print_verbose("Update icons: %s" % (Time.get_ticks_msec() - time))
	time = Time.get_ticks_msec()
	var to_remove: PackedInt32Array = []
	for i in _icon_queue.size():
		var queue = _icon_queue[i]
		if not queue[0]:
			to_remove.append(i)
		else:
			var _icon: ImageTexture = queue[0].get(queue[1])
			if _icon and _icon.get_size() == icon(queue[2]).get_size():
				_icon.update(icon(queue[2]).get_image())
			else:
				queue[0].set(queue[1], icon(queue[2]))
		await main.process_frame
	var removed := 0
	for i in to_remove:
		_icon_queue.remove_at(i - removed)
		removed += 1
	updating_icons = false
	print_verbose("Update icons queue: %s" % (Time.get_ticks_msec() - time))
	icons_changed.emit()


func _update_margin() -> void:
	set_constant("h_separation", "Button", _int_margin)
	set_constant("h_separation", "FoldableContainer", _int_margin)
	set_constant("button_margin", "Tree", _int_margin)
	set_constant("h_separation", "Tree", _int_margin)
	set_constant("inner_item_margin_bottom", "Tree", _int_margin)
	set_constant("inner_item_margin_top", "Tree", _int_margin)
	set_constant("inner_margin_left", "Tree", _int_margin)
	set_constant("inner_margin_right", "Tree", _int_margin)


func _update_padding() -> void:
	tab_panel_style.set_content_margin_all(_int_padding)
	tab_selected_style.set_content_margin_all(_int_padding)
	tab_unselected_style.set_content_margin_all(_int_padding)
	tab_disabled_style.set_content_margin_all(_int_padding)
	progress_background_style.set_content_margin_all(_int_padding)
	foldable_panel_style.content_margin_left = 8 + _int_padding
	foldable_panel_style.content_margin_right = _int_padding
	foldable_panel_style.content_margin_top = _int_padding
	foldable_panel_style.content_margin_bottom = _int_padding
	foldable_title_style.set_content_margin_all(_int_padding)
	foldable_title_hover_style.set_content_margin_all(_int_padding)
	foldable_title_collapsed_style.set_content_margin_all(_int_padding)
	foldable_title_collapsed_hover_style.set_content_margin_all(_int_padding)
	set_constant("arrow_margin", "OptionButton", _int_padding)
	set_constant("item_start_padding", "PopupMenu", _int_padding)
	set_constant("item_end_padding", "PopupMenu", _int_padding)


func _update_border_padding() -> void:
	panel_style.set_content_margin_all(_int_border_padding)
	popup_panel_style.set_content_margin_all(_int_border_padding)
	button_normal_style.set_content_margin_all(_int_border_padding)
	button_hover_style.set_content_margin_all(_int_border_padding)
	button_pressed_style.set_content_margin_all(_int_border_padding)
	button_disabled_style.set_content_margin_all(_int_border_padding)
	menu_button_normal_style.set_content_margin_all(_int_border_padding)
	menu_button_hover_style.set_content_margin_all(_int_border_padding)
	menu_button_pressed_style.set_content_margin_all(_int_border_padding)
	menu_button_disabled_style.set_content_margin_all(_int_border_padding)


func _update_corners() -> void:
	panel_style.set_corner_radius_all(_int_corners)
	button_normal_style.set_corner_radius_all(_int_corners)
	button_hover_style.set_corner_radius_all(_int_corners)
	button_pressed_style.set_corner_radius_all(_int_corners)
	button_disabled_style.set_corner_radius_all(_int_corners)
	menu_button_normal_style.corner_radius_top_left = _int_corners
	menu_button_normal_style.corner_radius_top_right = _int_corners
	menu_button_hover_style.corner_radius_top_left = _int_corners
	menu_button_hover_style.corner_radius_top_right = _int_corners
	menu_button_pressed_style.corner_radius_top_left = _int_corners
	menu_button_pressed_style.corner_radius_top_right = _int_corners
	menu_button_disabled_style.corner_radius_top_left = _int_corners
	menu_button_disabled_style.corner_radius_top_right = _int_corners
	grabber_style.set_corner_radius_all(_int_corners)
	grabber_highlight_style.set_corner_radius_all(_int_corners)
	slider_style.set_corner_radius_all(_int_corners)
	h_scroll_style.set_corner_radius_all(_int_corners)
	v_scroll_style.set_corner_radius_all(_int_corners)
	foldable_panel_style.corner_radius_bottom_left = _int_corners
	foldable_panel_style.corner_radius_bottom_right = _int_corners
	foldable_title_style.corner_radius_top_left = _int_corners
	foldable_title_style.corner_radius_top_right = _int_corners
	foldable_title_hover_style.corner_radius_top_left = _int_corners
	foldable_title_hover_style.corner_radius_top_right = _int_corners
	foldable_title_collapsed_style.set_corner_radius_all(_int_corners)
	foldable_title_collapsed_hover_style.set_corner_radius_all(_int_corners)
	var int_focus_border: int = round(max(corner_radius - 2, 0) * editor_scale)
	button_focus_style.set_corner_radius_all(int_focus_border)
	menu_button_focus_style.corner_radius_top_left = int_focus_border
	menu_button_focus_style.corner_radius_top_right = int_focus_border


func _update_border_width() -> void:
	panel_style.set_border_width_all(_int_border_width)
	popup_panel_style.set_border_width_all(max(_int_border_width, 1))
	button_focus_style.set_border_width_all(max(_int_border_width, 1))
	menu_button_focus_style.set_border_width_all(max(_int_border_width, 1))


func icon(icon_name: String) -> ImageTexture:
	return get_icon(icon_name, "icons")


func update_custom_font() -> void:
	var _font: FontFile = EditorTheme.load_font(custom_font)
	if _font:
		default_font.base_font = _font
	else:
		if default_font.base_font != DEFAULT_FONT:
			default_font.base_font = DEFAULT_FONT


static func load_font(font_path: String) -> FontFile:
	var font: FontFile = null
	if not font_path.is_empty() and font_path.is_valid_filename():
		if font_path.get_extension() in ["ttf", "otf", "woff2"]:
			if FileAccess.file_exists(font_path):
				var file = FileAccess.open(font_path, FileAccess.READ)
				if file:
					var font_data = FileAccess.get_file_as_bytes(font_path)
					if font_data.size() > 0:
						font = FontFile.new()
						font.data = font_data
	return font


## Returns the current class unique instance. [br]
## Don't use this method for classes that will be instantiated more than once.
static func get_singleton() -> EditorTheme:
	return _singleton


func _init():
	print_verbose("EditorTheme _init()")
	# Load icons.
	var generated_icons_dir := DirAccess.open("res://theme/generated_icons")
	for file in generated_icons_dir.get_files():
		if file.get_extension() != "pixel_icon":
			continue
		var pixel_icon := FileAccess.open("res://theme/generated_icons/" + file, FileAccess.READ)
		if pixel_icon:
			_icons[file.get_basename().to_pascal_case()] = pixel_icon.get_as_text()
			pixel_icon.close()
	# Set flat style boxes.
	set_stylebox("panel", "PanelContainer", panel_style)
	set_stylebox("panel", "Panel", panel_style)
	set_stylebox("panel", "PopupMenu", popup_panel_style)
	set_stylebox("panel", "PopupPanel", popup_panel_style)
	set_stylebox("panel", "AcceptDialog", popup_panel_style)
	set_stylebox("panel", "TabContainer", tab_panel_style)
	set_stylebox("tab_selected", "TabContainer", tab_selected_style)
	set_stylebox("tab_unselected", "TabContainer", tab_unselected_style)
	set_stylebox("tab_hovered", "TabContainer", tab_unselected_style)
	set_stylebox("tab_disabled", "TabContainer", tab_disabled_style)
	set_stylebox("tab_focus", "TabContainer", tab_focus_style)
	set_stylebox("normal", "Button", button_normal_style)
	set_stylebox("hover", "Button", button_hover_style)
	set_stylebox("pressed", "Button", button_pressed_style)
	set_stylebox("hover_pressed", "Button", button_pressed_style)
	set_stylebox("disabled", "Button", button_disabled_style)
	set_stylebox("focus", "Button", button_focus_style)
	set_stylebox("normal", "LineEdit", button_normal_style)
	set_stylebox("read_only", "LineEdit", button_disabled_style)
	set_stylebox("focus", "LineEdit", button_focus_style)
	set_stylebox("normal", "TextEdit", button_normal_style)
	set_stylebox("read_only", "TextEdit", button_disabled_style)
	set_stylebox("focus", "TextEdit", button_focus_style)
	set_stylebox("normal", "MenuButton", menu_button_normal_style)
	set_stylebox("hover", "MenuButton", menu_button_hover_style)
	set_stylebox("pressed", "MenuButton", menu_button_pressed_style)
	set_stylebox("hover_pressed", "MenuButton", menu_button_pressed_style)
	set_stylebox("disabled", "MenuButton", menu_button_disabled_style)
	set_stylebox("focus", "MenuButton", menu_button_focus_style)
	set_stylebox("hover", "PopupMenu", popup_hover_style)
	set_stylebox("background", "ProgressBar", progress_background_style)
	set_stylebox("fill", "ProgressBar", progress_fill_style)
	set_stylebox("grabber_area", "HSlider", grabber_style)
	set_stylebox("grabber_area", "VSlider", grabber_style)
	set_stylebox("grabber_area_highlight", "HSlider", grabber_highlight_style)
	set_stylebox("grabber_area_highlight", "VSlider", grabber_highlight_style)
	set_stylebox("slider", "HSlider", slider_style)
	set_stylebox("slider", "VSlider", slider_style)
	set_stylebox("grabber", "HScrollBar", grabber_style)
	set_stylebox("grabber", "VScrollBar", grabber_style)
	set_stylebox("grabber_highlight", "HScrollBar", grabber_highlight_style)
	set_stylebox("grabber_highlight", "VScrollBar", grabber_highlight_style)
	set_stylebox("grabber_pressed", "HScrollBar", grabber_highlight_style)
	set_stylebox("grabber_pressed", "VScrollBar", grabber_highlight_style)
	set_stylebox("scroll", "HScrollBar", h_scroll_style)
	set_stylebox("scroll", "VScrollBar", v_scroll_style)
	set_stylebox("focus", "FoldableContainer", button_focus_style)
	set_stylebox("panel", "FoldableContainer", foldable_panel_style)
	set_stylebox("title_panel", "FoldableContainer", foldable_title_style)
	set_stylebox("title_collapsed_panel", "FoldableContainer", foldable_title_collapsed_style)
	set_stylebox("title_hover_panel", "FoldableContainer", foldable_title_hover_style)
	set_stylebox("title_collapsed_hover_panel", "FoldableContainer", foldable_title_collapsed_hover_style)
	set_stylebox("up_background_hovered", "SpinBox", button_hover_style)
	set_stylebox("down_background_hovered", "SpinBox", button_hover_style)
	set_stylebox("up_background_pressed", "SpinBox", button_pressed_style)
	set_stylebox("down_background_pressed", "SpinBox", button_pressed_style)
	set_stylebox("custom_button", "Tree", button_normal_style)
	set_stylebox("custom_button_hover", "Tree", button_hover_style)
	set_stylebox("custom_button_pressed", "Tree", button_pressed_style)
	set_stylebox("focus", "Tree", button_focus_style)
	set_stylebox("panel", "Tree", button_normal_style)
	set_stylebox("selected", "Tree", popup_hover_style)
	set_stylebox("selected_focus", "Tree", popup_hover_style)
	set_stylebox("title_button_hover", "Tree", button_hover_style)
	set_stylebox("title_button_normal", "Tree", button_normal_style)
	set_stylebox("title_button_pressed", "Tree", button_pressed_style)
	set_type_variation("FlatPanel", "PanelContainer")
	set_stylebox("panel", "FlatPanel", popup_panel_style)
	# Set line style boxes.
	set_stylebox("labeled_separator_left", "PopupMenu", h_separator_style)
	set_stylebox("labeled_separator_right", "PopupMenu", h_separator_style)
	set_stylebox("separator", "PopupMenu", h_separator_style)
	set_stylebox("separator", "HSeparator", h_separator_style)
	set_stylebox("separator", "VSeparator", v_separator_style)
	# Set constants.
	v_separator_style.vertical = true
	tab_focus_style.draw_center = false
	button_focus_style.draw_center = false
	menu_button_focus_style.draw_center = false
	set_constant("draw_guides", "Tree", false)
	set_constant("draw_relationship_lines", "Tree", true)
	set_constant("side_margin", "TabContainer", 0)
	# Get values or set defaults.
	var settings = Settings.get_singleton()
	editor_scale = settings.get_value("theme", "editor_scale", 1.0, true)
	primary_color = settings.get_value("theme", "primary_color", Color(0.131, 0.152, 0.234, 1), true)
	secondary_color = settings.get_value("theme", "secondary_color", Color(0.226, 0.478, 0.921, 1), true)
	contrast = settings.get_value("theme", "contrast", 0.1, true)
	margin = settings.get_value("theme", "margin", 4, true)
	padding = settings.get_value("theme", "padding", 4, true)
	border_width = settings.get_value("theme", "border_width", 0, true)
	corner_radius = settings.get_value("theme", "corner_radius", 6, true)
	primary_color2_value = settings.get_value("theme", "primary_color2_value", 0.6, true)
	primary_color3_value = settings.get_value("theme", "primary_color3_value", 0.4, true)
	primary_color4_value = settings.get_value("theme", "primary_color4_value", 0.2, true)
	secondary_color2_value = settings.get_value("theme", "secondary_color2_value", 0.6, true)
	bg_color_value = settings.get_value("theme", "bg_color_value", 0.8, true)
	# Initialize theme font.
	default_font = FontVariation.new()
	font_outline = settings.get_value("theme", "font_outline", 0, true)
	font_color_override = settings.get_value("theme", "font_color_override", FontColorOverride.AUTO, true)
	custom_font = settings.get_value("theme", "custom_font", "", true)
	custom_font_color = settings.get_value("theme", "custom_font_color", Color(0.9, 0.9, 0.9), true)
	font_size = settings.get_value("theme", "font_size", 14, true)
	font_embolden = settings.get_value("theme", "font_embolden", 0.0, true)
	font_spacing_glyph = settings.get_value("theme", "font_spacing_glyph", 0.0, true)
	font_spacing_space = settings.get_value("theme", "font_spacing_space", 0.0, true)
	font_spacing_top = settings.get_value("theme", "font_spacing_top", 0.0, true)
	font_spacing_bottom = settings.get_value("theme", "font_spacing_bottom", 0.0, true)
	update_custom_font()
	# Final pass.
	_singleton = self


func _validate_property(property: Dictionary) -> void:
	var begin_hint := PackedStringArray(["primary_color", "secondary_color", "font_", "custom_font"])
	for hint in begin_hint:
		if property["name"].begins_with(hint):
			if property["name"] == "custom_font_color" and font_color_override != FontColorOverride.CUSTOM:
				property["usage"] = PROPERTY_USAGE_DEFAULT
			else:
				property["usage"] = PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_CUSTOM
			return
	var name_hint := PackedStringArray(["contrast", "editor_scale", "border_width", "corner_radius", "bg_color_value", "margin", "padding"])
	if property["name"] in name_hint:
		property["usage"] |= PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_CUSTOM
		return


func _property_can_revert(property: StringName) -> bool:
	var begin_hint := PackedStringArray(["primary_color", "secondary_color", "font_", "custom_font"])
	for hint in begin_hint:
		if property.begins_with(hint):
			return true
	var name_hint := PackedStringArray(["contrast", "editor_scale", "border_width", "corner_radius", "bg_color_value", "margin", "padding"])
	return property in name_hint


func _property_get_revert(property: StringName) -> Variant:
	if _property_can_revert(property):
		return Settings.get_singleton().get_default_value("theme", property)
	return null


func _property_get_tooltip(property: StringName) -> String:
	match property:
		"primary_color":
			return "The theme primary color."
		"secondary_color":
			return "The theme secondary color."
		"contrast":
			return "The theme contrast."
		"margin":
			return "The theme margin."
		"padding":
			return "The theme padding."
		"editor_scale":
			return "The theme editor scale."
		"border_width":
			return "The theme border width."
		"corner_radius":
			return "The theme corner radius."
		"bg_color_value":
			return "The theme background contrast value."
		"primary_color2_value":
			return "The theme primary color 2 contrast value."
		"primary_color3_value":
			return "The theme primary color 3 contrast value."
		"primary_color4_value":
			return "The theme primary color 4 contrast value."
		"secondary_color2_value":
			return "The theme secondary color 2 contrast value."
		"font_color_override":
			return "The theme font color override."
		"custom_font":
			return "The theme custom font."
		"custom_font_color":
			return "The theme custom font color."
		"font_size":
			return "The theme font size."
		"font_embolden":
			return "The theme font embolden."
		"font_outline":
			return "The theme font outline."
		"font_spacing_glyph":
			return "The theme font spacing glyph."
		"font_spacing_space":
			return "The theme font spacing space."
		"font_spacing_top":
			return "The theme font spacing top."
		"font_spacing_bottom":
			return "The theme font spacing bottom."
		_:
			return ""
