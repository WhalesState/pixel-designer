@tool
@icon("./icon.svg")
class_name ExtendableContainer
extends Container

@export var expanded := true:
	set(value):
		expanded = value
		for child in get_children():
			child.visible = expanded
		queue_redraw()

@export var title := "":
	set(value):
		title = value
		queue_redraw()

@export_enum("Left:%s" % HORIZONTAL_ALIGNMENT_LEFT, "Center:%s" % HORIZONTAL_ALIGNMENT_CENTER, "Right:%s" % HORIZONTAL_ALIGNMENT_RIGHT) var horizontal_alignment: int = HORIZONTAL_ALIGNMENT_LEFT:
	set(value):
		horizontal_alignment = value
		queue_redraw()

@export var title_font_size := 16:
	set(value):
		title_font_size = value
		queue_redraw()

@export var title_font_color := Color.WHITE:
	set(value):
		title_font_color = value
		queue_redraw()

@export var arrow_icon := get_theme_icon("arrow", "Tree"):
	set(value):
		arrow_icon = value
		queue_redraw()

@export var arrow_collapsed_icon := get_theme_icon("arrow_collapsed", "Tree"):
	set(value):
		arrow_collapsed_icon = value
		queue_redraw()

@export var panel_style := _create_flat_stylebox(Color(0.1, 0.1, 0.1, 0.6), [16, 4, 4, 4], [0, 0, 8, 8]):
	set(value):
		panel_style = value
		queue_redraw()

@export var title_style := _create_flat_stylebox(Color(0.2, 0.2, 0.2), [4, 4, 4, 4], [8, 8, 0, 0]):
	set(value):
		title_style = value
		queue_redraw()

@export var collapsed_title_style := _create_flat_stylebox(Color(0.2, 0.2, 0.2), [4, 4, 4, 4], [8, 8, 8, 8]):
	set(value):
		collapsed_title_style = value
		queue_redraw()

var title_font := get_theme_default_font()
var _title_height := 0
var is_hovered := false


func _init():
	var cur_theme = ThemeDB.get_project_theme()
	if cur_theme:
		if not cur_theme.get_type_list().has("ExtendableContainer"):
			cur_theme.add_type("ExtendableContainer")
		
		if not cur_theme.get_type_variation_base("ExtendableContainer") == "Container":
			cur_theme.set_type_variation("ExtendableContainer", "Container")
		theme_type_variation = "ExtendableContainer"
		
		if not cur_theme.has_stylebox("panel", "ExtendableContainer"):
			panel_style = _create_flat_stylebox()
			cur_theme.set_stylebox("panel", "ExtendableContainer", panel_style)
		else:
			panel_style = cur_theme.get_stylebox("panel", "ExtendableContainer")
		
		if not cur_theme.has_stylebox("title_style", "ExtendableContainer"):
			title_style = _create_flat_stylebox()
			cur_theme.set_stylebox("title_style", "ExtendableContainer", title_style)
		else:
			title_style = cur_theme.get_stylebox("title_style", "ExtendableContainer")
		
		if not cur_theme.has_stylebox("collapsed_title_style", "ExtendableContainer"):
			collapsed_title_style = _create_flat_stylebox()
			cur_theme.set_stylebox("collapsed_title_style", "ExtendableContainer", collapsed_title_style)
		else:
			collapsed_title_style = cur_theme.get_stylebox("collapsed_title_style", "ExtendableContainer")
		
		if not cur_theme.has_icon("arrow", "ExtendableContainer"):
			cur_theme.set_icon("arrow", "ExtendableContainer", arrow_icon)
		else:
			arrow_icon = cur_theme.get_icon("arrow", "ExtendableContainer")
		
		if not cur_theme.has_icon("arrow_collapsed", "ExtendableContainer"):
			cur_theme.set_icon("arrow_collapsed", "ExtendableContainer", arrow_collapsed_icon)
		else:
			arrow_collapsed_icon = cur_theme.get_icon("arrow_collapsed", "ExtendableContainer")
		
		if not cur_theme.has_font("title_font", "ExtendableContainer"):
			cur_theme.set_font("title_font", "ExtendableContainer", cur_theme.default_font)
		else:
			title_font = cur_theme.get_font("title_font", "ExtendableContainer")
		
		if not cur_theme.has_font_size("title_font_size", "ExtendableContainer"):
			cur_theme.set_font_size("title_font_size", "ExtendableContainer", title_font_size)
		else:
			title_font_size = cur_theme.get_font_size("title_font_size", "ExtendableContainer")
		
		if not cur_theme.has_color("title_font_color", "ExtendableContainer"):
			cur_theme.set_color("title_font_color", "ExtendableContainer", title_font_color)
		else:
			title_font_color = cur_theme.get_color("title_font_color", "ExtendableContainer")


func _gui_input(ev: InputEvent):
	if not (ev is InputEventMouseButton and ev.button_index == MOUSE_BUTTON_LEFT and ev.pressed):
		return
	if ev.position.y <= _title_height:
		expanded = not expanded


func _create_flat_stylebox(bg_color := Color(0.6, 0.6, 0.6),
		content_margin := PackedInt32Array([-1, -1, -1, -1]),
		corner_radius := PackedInt32Array([0, 0, 0, 0]),
		border_color := Color(0.8, 0.8, 0.8),
		border_width := PackedInt32Array([0, 0, 0, 0])) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = bg_color
	style.border_color = border_color
	var borders := ["left", "top", "right", "bottom"]
	var corners := ["top_left", "top_right", "bottom_right", "bottom_left"]
	for i in content_margin.size():
		style.set("content_margin_%s" % borders[i], content_margin[i])
	for i in border_width.size():
		style.set("border_width_%s" % borders[i], border_width[i])
	for i in corner_radius.size():
		style.set("corner_radius_%s" % corners[i], corner_radius[i])
	return style


func _notification(what: int):
	if not what == NOTIFICATION_SORT_CHILDREN:
		return
	for child in get_children():
		if not child is Control:
			return
		child.position = panel_style.get_offset()
		child.position.y += _title_height
		match child.size_flags_horizontal:
			SIZE_FILL:
				child.size.x = size.x - panel_style.get_minimum_size().x
			SIZE_SHRINK_BEGIN:
				child.size.x = child.get_combined_minimum_size().x
			SIZE_SHRINK_CENTER:
				child.size.x = 0
				child.position.x += (size.x - panel_style.get_minimum_size().x - child.get_combined_minimum_size().x) / 2
			SIZE_SHRINK_END:
				child.size.x = 0
				child.position.x += size.x - panel_style.get_minimum_size().x - child.get_combined_minimum_size().x
		match child.size_flags_vertical:
			SIZE_FILL:
				child.size.y = size.y - panel_style.get_minimum_size().y
				child.size.y -= _title_height
			SIZE_SHRINK_BEGIN:
				child.size.y = child.get_combined_minimum_size().y
			SIZE_SHRINK_CENTER:
				child.size.y = 0
				child.position.y += (size.y - panel_style.get_minimum_size().y - child.get_combined_minimum_size().y) / 2
				child.position.y -= _title_height / 2
			SIZE_SHRINK_END:
				child.size.y = 0
				child.position.y += size.y - panel_style.get_minimum_size().y - child.get_combined_minimum_size().y
				child.position.y -= _title_height


func _get_minimum_size() -> Vector2:
	if not expanded:
		return Vector2.ZERO
	var minsize = panel_style.get_minimum_size()
	var combined_minsize := Vector2.ZERO
	for child in get_children():
		combined_minsize.x = max(combined_minsize.x, child.get_combined_minimum_size().x)
		combined_minsize.y = max(combined_minsize.y, child.get_combined_minimum_size().y)
	minsize += combined_minsize
	minsize.y += _title_height
	return minsize


func _draw():
	var icon = arrow_icon if expanded else arrow_collapsed_icon
	
	var title_size = Vector2(size.x, title_style.get_minimum_size().y + title_font.get_height(title_font_size))
	if icon:
		title_size.y = max(title_size.y, title_style.get_minimum_size().y + icon.get_height())
	
	draw_style_box(title_style if expanded else collapsed_title_style, Rect2(Vector2.ZERO, title_size))
	_title_height = title_size.y
	
	var title_position = title_style.get_offset()
	title_position.y += title_font.get_ascent(title_font_size)
	if icon:
		title_position.x += icon.get_width()
	
	if icon:
		if title_font.get_height(title_font_size) < icon.get_height():
			draw_texture(icon, title_style.get_offset())
			title_position.y += (icon.get_height() - title_font.get_ascent(title_font_size)) / 2
		else:
			draw_texture(icon, title_style.get_offset() + Vector2(0, (title_font.get_height(title_font_size) - icon.get_height()) / 2))
	var title_width = size.x - title_style.get_minimum_size().x
	if icon:
		title_width -= icon.get_width()
	draw_string(title_font, title_position, title, horizontal_alignment, title_width, title_font_size, title_font_color)
	if expanded:
		draw_style_box(panel_style, Rect2(0, _title_height, size.x, size.y - _title_height))
	custom_minimum_size.y = _title_height
