@tool
class_name EditorTheme
extends Theme

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

@export_range(1, 2) var editor_scale := 1:
	set(value):
		value = clampi(value, 1, 2)
		if value != editor_scale:
			editor_scale = value
			Settings.get_singleton().set_editor_value("theme", "editor_scale", editor_scale)
			update_theme()

var is_dark_theme := false

var current_font: String:
	set(value):
		if not fonts.has(value):
			if not fonts.keys().is_empty():
				value = fonts.keys()[0]
			else:
				return
		if value != current_font:
			current_font = value
			Settings.get_singleton().set_editor_value("theme", "current_font", current_font)
			update_theme()

var fonts := {}
var icons := {}

var icon_queue := []

static var singleton: EditorTheme


func add_to_icon_queue(node: Node, property_name: String, icon_name: String):
	icon_queue.append([node, property_name, icon_name])


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
#    (0, 0, 1) = primary_color contrasted (60%) (blue)
#    (1, 1, 0) = primary_color contrasted (40%) (yellow)
#    (1, 0, 1) = primary_color contrasted (20%) (magneta)
#    (0, 1, 1) = lerp secondary > primary (60%) (cyan)
func _update_theme():
	# Set font.
	if not current_font.is_empty() and fonts.has(current_font):
		var font: PixelFont = fonts[current_font]
		default_font_size = font.size * editor_scale
		default_font.base_font = font
		default_font.spacing_glyph = font.spacing_glyph * editor_scale
		default_font.spacing_space = font.spacing_space * editor_scale
		default_font.spacing_top = font.spacing_top * editor_scale
		default_font.spacing_bottom = font.spacing_bottom * editor_scale
	else:
		default_font.base_font = null
	# Set colors.
	var font_color := Color(0.9, 0.9, 0.9) if is_dark_theme else Color(0.05, 0.05, 0.05)
	var contrasted_color := contrast_color(primary_color, contrast)
	var bg_color := primary_color.lerp(contrasted_color, 0.8)
	# set icons.
	for pixel_icon in icons.keys():
		var svg = icons[pixel_icon]
		svg = svg.replace("\"#fff\"", "\"#%s\"" % font_color.to_html(false))
		svg = svg.replace("\"#f00\"", "\"#%s\"" % primary_color.to_html(false))
		svg = svg.replace("\"#0f0\"", "\"#%s\"" % secondary_color.to_html(false))
		svg = svg.replace("\"#00f\"", "\"#%s\"" % primary_color.lerp(contrasted_color, 0.6).to_html(false))
		svg = svg.replace("\"#ff0\"", "\"#%s\"" % primary_color.lerp(contrasted_color, 0.4).to_html(false))
		svg = svg.replace("\"#f0f\"", "\"#%s\"" % primary_color.lerp(contrasted_color, 0.2).to_html(false))
		svg = svg.replace("\"#0ff\"", "\"#%s\"" % secondary_color.lerp(primary_color, 0.6).to_html(false))
		var img := Image.new()
		img.load_svg_from_string(svg, editor_scale)
		set_icon(pixel_icon, "icons", ImageTexture.create_from_image(img))
	# Panel.
	var style := StyleBoxTexture.new()
	style.texture = icon("GuiPanel")
	style.set_texture_margin_all(2 * editor_scale)
	set_stylebox("panel", "PanelContainer", style)
	set_stylebox("panel", "Panel", style)
	# Button.
	style = StyleBoxTexture.new()
	style.texture = icon("GuiButtonNormal")
	style.set_texture_margin_all(4 * editor_scale)
	set_stylebox("normal", "Button", style)
	style = StyleBoxTexture.new()
	style.texture = icon("GuiButtonHover")
	style.set_texture_margin_all(4 * editor_scale)
	set_stylebox("hover", "Button", style)
	style = StyleBoxTexture.new()
	style.texture = icon("GuiButtonPressed")
	style.set_texture_margin_all(4 * editor_scale)
	set_stylebox("pressed", "Button", style)
	style = StyleBoxTexture.new()
	style.texture = icon("GuiFocus")
	style.set_texture_margin_all(4 * editor_scale)
	set_stylebox("focus", "Button", style)
	var empty := StyleBoxEmpty.new()
	empty.set_content_margin_all(4 * editor_scale)
	set_stylebox("disabled", "Button", empty)
	set_color("icon_focus_color", "Button", font_color)
	set_color("font_focus_color", "Button", font_color)
	set_color("font_hover_color", "Button", font_color)
	set_color("icon_hover_color", "Button", font_color)
	var icon_color = font_color
	icon_color.a = 0.8
	set_color("icon_normal_color", "Button", icon_color)
	set_color("font_color", "Button", icon_color)
	set_color("icon_pressed_color", "Button", icon_color)
	set_color("font_pressed_color", "Button", icon_color)
	icon_color.a = 0.7
	set_color("icon_disabled_color", "Button", icon_color)
	set_color("font_disabled_color", "Button", icon_color)
	# SplitterContainer.
	set_color("hover_color", "SplitterContainer", icon_color)
	icon_color.a = 0.6
	set_color("normal_color", "SplitterContainer", icon_color)
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


static func get_singleton() -> EditorTheme:
	return singleton


func _init():
	print_verbose("EditorTheme _init()")
	default_font = FontVariation.new()
	# Generate pixel fonts.
	if OS.has_feature("editor"):
		for file in DirAccess.get_files_at("res://theme/fonts"):
			if not file.get_extension() == "ttf":
				continue
			if not FileAccess.file_exists("res://theme/fonts/" + file + ".import"):
				continue
			var config := ConfigFile.new()
			config.load("res://theme/fonts/" + file + ".import")
			var params: Array = config.get_value("params", "preload", [])
			if params.is_empty():
				continue
			var font_data: PackedStringArray = params[0]["name"].split(",")
			var font_file : FontFile = ResourceLoader.load("res://theme/fonts/" + file, "FontFile", ResourceLoader.CACHE_MODE_REUSE)
			var pixel_font_data := {}
			pixel_font_data["data"] = font_file.data
			pixel_font_data["name"] = font_data[0]
			pixel_font_data["file"] = "res://theme/fonts/" + file.get_basename() + ".pixel_font"
			var properties := PackedStringArray(["", "size", "spacing_glyph", "spacing_space", "spacing_top", "spacing_bottom"])
			for i in range(1, properties.size()):
				if font_data.size() > i:
					pixel_font_data[properties[i]] = font_data[i].to_int()
				else:
					pixel_font_data[properties[i]] = 0
			var new_file = FileAccess.open(pixel_font_data["file"], FileAccess.WRITE)
			new_file.store_var(pixel_font_data)
			new_file.close()
	# Load internal fonts.
	var font_files := PackedStringArray()
	for file in DirAccess.get_files_at("res://theme/fonts"):
		if not file.get_extension() == "pixel_font":
			continue
		if OS.has_feature("editor"):
			if not FileAccess.file_exists("res://theme/fonts/" + file.get_basename() + ".ttf"):
				DirAccess.remove_absolute("res://theme/fonts/" + file)
				continue
		font_files.append("res://theme/fonts/" + file)
	# Load user fonts.
	if not DirAccess.dir_exists_absolute(OS.get_user_data_dir() + "/fonts"):
		DirAccess.make_dir_absolute(OS.get_user_data_dir() + "/fonts")
	else:
		for file in DirAccess.get_files_at(OS.get_user_data_dir() + "/fonts"):
			if not file.get_extension() == "pixel_font":
				continue
			font_files.append(OS.get_user_data_dir() + "/fonts/" + file)
	for file in font_files:
		var pixel_font_data = FileAccess.open(file, FileAccess.READ).get_var()
		var pixel_font := PixelFont.new()
		for key in pixel_font_data.keys():
			pixel_font.set(key, pixel_font_data[key])
		fonts[pixel_font.name] = pixel_font
	# Generate pixel icons.
	for file in DirAccess.get_files_at("res://theme/icons"):
		if file.get_extension() != "svg":
			continue
		var svg_file := FileAccess.open("res://theme/icons/" + file, FileAccess.READ)
		if not svg_file:
			continue
		var svg = svg_file.get_as_text()
		svg_file.close()
		var pixel_icon := FileAccess.open("res://theme/icons/" + file.get_basename() + ".pixel_icon", FileAccess.WRITE)
		pixel_icon.store_string(svg)
		pixel_icon.close()
	# Load icons.
	for file in DirAccess.get_files_at("res://theme/icons"):
		if file.get_extension() != "pixel_icon":
			continue
		if OS.has_feature("editor"):
			if not FileAccess.file_exists("res://theme/icons/" + file.get_basename() + ".svg"):
				DirAccess.remove_absolute("res://theme/icons/" + file)
				continue
		var pixel_icon := FileAccess.open("res://theme/icons/" + file, FileAccess.READ)
		if pixel_icon:
			icons[file.get_basename().to_pascal_case()] = pixel_icon.get_as_text()
			pixel_icon.close()
	# get default values
	primary_color = Settings.get_singleton().get_editor_value("theme", "primary_color", Color(0.131259, 0.15223, 0.2342, 1))
	secondary_color = Settings.get_singleton().get_editor_value("theme", "secondary_color", Color(0.226313, 0.478181, 0.921924, 1))
	contrast = Settings.get_singleton().get_editor_value("theme", "contrast", 0.1)
	editor_scale = Settings.get_singleton().get_editor_value("theme", "editor_scale", 1)
	current_font = Settings.get_singleton().get_editor_value("theme", "current_font", "")
	# Final pass.
	singleton = self


class PixelFont:
	extends FontFile
	
	var name := "Pixel Font"
	var size := 16
	var spacing_glyph := 0
	var spacing_space := 0
	var spacing_top := 0
	var spacing_bottom := 0
	var file := ""
	
	
	func _init():
		antialiasing = TextServer.FONT_ANTIALIASING_NONE
		subpixel_positioning = TextServer.SUBPIXEL_POSITIONING_DISABLED
		hinting = TextServer.HINTING_NONE
