@tool
class_name EditorTheme
extends Theme

const DEFAULT_FONT = preload("res://theme/fonts/NotoSans_Regular.woff2")

@export_color_no_alpha var primary_color: Color:
	set(value):
		value.a = 1.0
		if primary_color != value:
			primary_color = value
			is_dark_theme = primary_color.get_luminance() <= 0.5
			Settings.get_singleton().set_editor_value("theme", "primary_color", primary_color)
			update_theme()

@export_color_no_alpha var secondary_color: Color:
	set(value):
		value.a = 1.0
		if secondary_color != value:
			secondary_color = value
			Settings.get_singleton().set_editor_value("theme", "secondary_color", secondary_color)
			update_theme()

@export_range(-1.0, 1.0, 0.01) var contrast: float:
	set(value):
		value = clampf(value, -1.0, 1.0)
		if value != contrast:
			contrast = value
			Settings.get_singleton().set_editor_value("theme", "contrast", contrast)
			update_theme()

@export_range(0, 3) var border_width: int:
	set(value):
		value = clampi(value, 0, 3)
		if value != border_width:
			border_width = value
			Settings.get_singleton().set_editor_value("theme", "border_width", border_width)
			update_theme()

@export_range(0, 8) var corner_radius: int:
	set(value):
		value = clampi(value, 0, 8)
		if value != corner_radius:
			corner_radius = value
			Settings.get_singleton().set_editor_value("theme", "corner_radius", corner_radius)
			update_theme()

@export var flat_corners: bool:
	set(value):
		if value != flat_corners:
			flat_corners = value
			Settings.get_singleton().set_editor_value("theme", "flat_corners", flat_corners)
			update_theme()

@export_range(0, 2) var font_outline: int:
	set(value):
		if value != font_outline:
			font_outline = value
			Settings.get_singleton().set_editor_value("theme", "font_outline", font_outline)
			update_theme()

@export_range(1, 2) var editor_scale := 1:
	set(value):
		value = clampi(value, 1, 2)
		if value != editor_scale:
			editor_scale = value
			Settings.get_singleton().set_editor_value("theme", "editor_scale", editor_scale)
			update_theme()

var is_dark_theme := false

var icons := {}

var icon_queue := []

## For "panel" in [Panel, PanelContainer, TabContainer].
var panel_style := PixelStyleBox.new()
## For "tab_selected" in [TabContainer].
var tab_selected_style := PixelStyleBox.new()
## For "tab_unselectd" and "tab_hovered" in [TabContainer].
var tab_unselected_style := PixelStyleBox.new()
## For "tab_disabled" in [TabContainer].
var tab_disabled_style := PixelStyleBox.new()
## For "tab_focus" in [TabContainer].
var tab_focus_style := PixelStyleBox.new()
## For "normal" in [Button].
var button_normal_style := PixelStyleBox.new()
## For "hover" in [Button].
var button_hover_style := PixelStyleBox.new()
## For "pressed" in [Button].
var button_pressed_style := PixelStyleBox.new()
## For "focus" in [Button].
var button_focus_style := PixelStyleBox.new()
## For "disabled" in [Button].
var button_disabled_style := PixelStyleBox.new()


## [b]PRIVATE[/b] used for unique classes to easily access them with `ClassName.get_singleton()` from any other script.
static var _singleton: EditorTheme


func add_to_icon_queue(node: Node, property_name: String, icon_name: String):
	icon_queue.append([node, property_name, icon_name])
	update_theme()


func contrast_color(color: Color, value: float) -> Color:
	if is_equal_approx(value, 0):
		return color
	elif value > 0.0:
		return color.lightened(value)
	else:
		return color.darkened(value * -1)


func update_theme():
	MessageQueue.get_singleton().queue_call(_update_theme)


# Icons:
#    (1, 1, 1) = font_color                     (white)
#    (1, 0, 0) = primary_color                  (red)
#    (0, 1, 0) = secondary_color                (green)
#    (0, 0, 1) = primary_color2 contrasted (60%) (blue)
#    (1, 1, 0) = primary_color3 contrasted (40%) (yellow)
#    (1, 0, 1) = primary_color4 contrasted (20%) (magneta)
#    (0, 1, 1) = secondary_color2 lerp to primary (60%) (cyan)
# FIXME: Icons should use modulation to change colors instead of setting them directly to their svg file. Modulate doesn't work for black color.
func _update_theme():
	# Set colors.
	var font_color := Color(0.9, 0.9, 0.9) if is_dark_theme else Color(0.05, 0.05, 0.05)
	var contrasted_color := contrast_color(primary_color, contrast)
	var primary_color2 := primary_color.lerp(contrasted_color, 0.6)
	var primary_color3 := primary_color.lerp(contrasted_color, 0.4)
	var primary_color4 := primary_color.lerp(contrasted_color, 0.2)
	var secondary_color2 := secondary_color.lerp(primary_color, 0.6)
	var bg_color := primary_color.lerp(contrasted_color, 0.8)
	# set icons.
	for pixel_icon in icons.keys():
		var svg = icons[pixel_icon]
		svg = svg.replace("\"#fff\"", "\"#%s\"" % font_color.to_html(false))
		svg = svg.replace("\"#f00\"", "\"#%s\"" % primary_color.to_html(false))
		svg = svg.replace("\"#0f0\"", "\"#%s\"" % secondary_color.to_html(false))
		svg = svg.replace("\"#00f\"", "\"#%s\"" % primary_color2.to_html(false))
		svg = svg.replace("\"#ff0\"", "\"#%s\"" % primary_color3.to_html(false))
		svg = svg.replace("\"#f0f\"", "\"#%s\"" % primary_color4.to_html(false))
		svg = svg.replace("\"#0ff\"", "\"#%s\"" % secondary_color2.to_html(false))
		var img := Image.new()
		img.load_svg_from_string(svg, editor_scale)
		set_icon(pixel_icon, "icons", ImageTexture.create_from_image(img))
	# base_style.scale = editor_scale
	# base_style.border_color = font_color
	# base_style.border_width = border_width
	# base_style.flat_corners = flat_corners
	# base_style.set_corner_all(corner_radius)

	# For "panel" in [Panel, PanelContainer, TabContainer].
	panel_style.scale = editor_scale
	panel_style.fill_color = primary_color3
	panel_style.border_color = font_color
	panel_style.border_width = border_width
	panel_style.flat_corners = flat_corners
	panel_style.set_corner_all(corner_radius)
	# For "tab_selected" in [TabContainer].
	tab_selected_style.scale = editor_scale
	tab_selected_style.fill_color = primary_color3
	tab_selected_style.border_color = font_color
	tab_selected_style.border_width = border_width
	tab_selected_style.flat_corners = flat_corners
	tab_selected_style.set_corner_all(corner_radius)
	tab_selected_style.expand_bottom = 8 * editor_scale
	tab_selected_style.expand_margin_bottom = border_width * editor_scale
	# For "tab_unselected" and "tab_hovered" in [TabContainer].
	tab_unselected_style.scale = editor_scale
	tab_unselected_style.fill_color = primary_color4
	tab_unselected_style.border_color = font_color
	tab_unselected_style.border_width = border_width
	tab_unselected_style.flat_corners = flat_corners
	tab_unselected_style.set_corner_all(corner_radius)
	tab_unselected_style.expand_bottom = 8 * editor_scale
	# For "tab_disabled" in [TabContainer].
	tab_disabled_style.scale = editor_scale
	tab_disabled_style.fill_color = primary_color4
	tab_disabled_style.fill_color.a = 0.6
	tab_disabled_style.border_color = font_color
	tab_disabled_style.border_color.a = 0.6
	tab_disabled_style.border_width = border_width
	tab_disabled_style.flat_corners = flat_corners
	tab_disabled_style.set_corner_all(corner_radius)
	tab_disabled_style.expand_bottom = 8 * editor_scale
	# For "tab_focus" in [TabContainer].
	tab_focus_style.scale = editor_scale
	tab_focus_style.fill_color.a = 0.0
	tab_focus_style.border_color = secondary_color
	tab_focus_style.border_width = maxi(1, border_width)
	tab_focus_style.flat_corners = flat_corners
	tab_focus_style.set_corner_all(corner_radius)
	tab_focus_style.expand_bottom = 8 * editor_scale
	# TabContainer colors.
	var color = font_color
	set_color("font_hovered_color", "TabContainer", color)
	set_color("drop_mark_color", "TabContainer", color)
	color.a = 0.9
	set_color("font_selected_color", "TabContainer", color)
	color.a = 0.8
	set_color("font_unselected_color", "TabContainer", color)
	color.a = 0.6
	set_color("font_disabled_color", "TabContainer", color)
	set_color("font_outline_color", "TabContainer", bg_color)
	# TabContainer constants.
	set_constant("side_margin", "TabContainer", maxi(corner_radius, border_width) * editor_scale)
	set_constant("icon_separation", "TabContainer", 2 * editor_scale)
	set_constant("font_outline_size", "TabContainer", font_outline * editor_scale)
	# TODO: Create new icons for TabContainer.
	# Button styleboxes.
	button_normal_style.scale = editor_scale
	button_normal_style.fill_color = primary_color4
	button_normal_style.border_color = font_color
	button_normal_style.border_width = border_width
	button_normal_style.flat_corners = flat_corners
	button_normal_style.set_corner_all(corner_radius)
	button_hover_style.scale = editor_scale
	button_hover_style.fill_color = primary_color2
	button_hover_style.border_color = font_color
	button_hover_style.border_width = border_width
	button_hover_style.flat_corners = flat_corners
	button_hover_style.set_corner_all(corner_radius)
	button_pressed_style.scale = editor_scale
	button_pressed_style.fill_color = primary_color
	button_pressed_style.border_color = font_color
	button_pressed_style.border_width = border_width
	button_pressed_style.flat_corners = flat_corners
	button_pressed_style.set_corner_all(corner_radius)
	button_focus_style.scale = editor_scale
	button_focus_style.fill_color = Color(0, 0, 0, 0)
	button_focus_style.border_color = secondary_color
	button_focus_style.border_width = maxi(border_width, 1)
	button_focus_style.flat_corners = flat_corners
	button_focus_style.set_corner_all(corner_radius)
	button_disabled_style.scale = editor_scale
	button_disabled_style.fill_color = primary_color4
	button_disabled_style.fill_color.a = 0.6
	button_disabled_style.border_color = font_color
	button_disabled_style.border_color.a = 0.6
	button_disabled_style.border_width = border_width
	button_disabled_style.flat_corners = flat_corners
	button_disabled_style.set_corner_all(corner_radius)
	# Button Color.
	set_color("icon_pressed_color", "Button", secondary_color)
	set_color("icon_hover_pressed_color", "Button", secondary_color)
	set_color("font_pressed_color", "Button", secondary_color)
	color.a = 1.0
	set_color("font_hover_color", "Button", color)
	set_color("icon_hover_color", "Button", color)
	color.a = 0.8
	set_color("icon_focus_color", "Button", color)
	set_color("font_focus_color", "Button", color)
	color.a = 0.6
	set_color("icon_normal_color", "Button", color)
	set_color("font_color", "Button", color)
	color.a = 0.4
	set_color("icon_disabled_color", "Button", color)
	set_color("font_disabled_color", "Button", color)
	# SplitterContainer.
	color.a = 0.6
	set_color("hover_color", "SplitterContainer", color)
	color.a = 0.4
	set_color("normal_color", "SplitterContainer", color)
	set_color("pressed_color", "SplitterContainer", secondary_color)
	# BG
	Root.get_singleton().clear_color = bg_color
	# Queue
	var to_remove: PackedInt32Array = []
	for i in icon_queue.size():
		var queue = icon_queue[i]
		if not queue[0]:
			to_remove.append(i)
		else:
			queue[0].set(queue[1], icon(queue[2]))
	var removed := 0
	for i in to_remove:
		icon_queue.remove_at(i - removed)
		removed += 1
	print_verbose("REMOVED: %s icons from queue" % removed)


func icon(icon_name: String) -> ImageTexture:
	return get_icon(icon_name, "icons")


func update_custom_font() -> void:
	var custom_font: FontFile = EditorTheme.load_font(Settings.get_singleton().get_editor_value("theme", "custom_font", ""))
	if custom_font:
		default_font.base_font = custom_font
	else:
		default_font.base_font = DEFAULT_FONT


func update_font_variation() -> void:
	default_font.variation_embolden = Settings.get_singleton().get_editor_value("theme", "font_embolden", 0.0)
	default_font.spacing_glyph = Settings.get_singleton().get_editor_value("theme", "font_spacing_glyph", 0.0)
	default_font.spacing_space = Settings.get_singleton().get_editor_value("theme", "font_spacing_space", 0.0)
	default_font.spacing_top = Settings.get_singleton().get_editor_value("theme", "font_spacing_top", 0.0)
	default_font.spacing_bottom = Settings.get_singleton().get_editor_value("theme", "font_spacing_bottom", 0.0)
	default_font_size = Settings.get_singleton().get_editor_value("theme", "font_size", 14)


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
	# Initialize theme font.
	default_font = FontVariation.new()
	update_custom_font()
	update_font_variation()
	# Load icons.
	var generated_icons_dir := DirAccess.open("res://theme/generated_icons")
	for file in generated_icons_dir.get_files():
		if file.get_extension() != "pixel_icon":
			continue
		var pixel_icon := FileAccess.open("res://theme/generated_icons/" + file, FileAccess.READ)
		if pixel_icon:
			icons[file.get_basename().to_pascal_case()] = pixel_icon.get_as_text()
			pixel_icon.close()
	# Set style boxes.
	set_stylebox("panel", "PanelContainer", panel_style)
	set_stylebox("panel", "Panel", panel_style)
	set_stylebox("panel", "TabContainer", panel_style)
	set_stylebox("tab_selected", "TabContainer", tab_selected_style)
	set_stylebox("tab_unselected", "TabContainer", tab_unselected_style)
	set_stylebox("tab_hovered", "TabContainer", tab_unselected_style)
	set_stylebox("tab_disabled", "TabContainer", tab_disabled_style)
	set_stylebox("tab_focus", "TabContainer", tab_focus_style)
	set_stylebox("normal", "Button", button_normal_style)
	set_stylebox("hover", "Button", button_hover_style)
	set_stylebox("pressed", "Button", button_pressed_style)
	set_stylebox("hover_pressed", "Button", button_pressed_style)
	set_stylebox("focus", "Button", button_focus_style)
	set_stylebox("disabled", "Button", button_disabled_style)
	# get default values
	primary_color = Settings.get_singleton().get_editor_value("theme", "primary_color", Color(0.131259, 0.15223, 0.2342, 1))
	secondary_color = Settings.get_singleton().get_editor_value("theme", "secondary_color", Color(0.226313, 0.478181, 0.921924, 1))
	contrast = Settings.get_singleton().get_editor_value("theme", "contrast", 0.1)
	editor_scale = Settings.get_singleton().get_editor_value("theme", "editor_scale", 1)
	border_width = Settings.get_singleton().get_editor_value("theme", "border_width", 2.0)
	corner_radius = Settings.get_singleton().get_editor_value("theme", "corner_radius", 6.0)
	flat_corners = Settings.get_singleton().get_editor_value("theme", "flat_corners", false)
	font_outline = Settings.get_singleton().get_editor_value("theme", "font_outline", 0)
	# Final pass.
	_singleton = self
