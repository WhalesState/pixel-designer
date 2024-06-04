"""*********************************************************************
*                        This file is Part of                          *
*                           Pixel Designer                             *
************************************************************************
* Copyright (c) 2023-present (Erlend Sogge Heggen), (Mounir Tohami).   *
* License : PolyForm Strict License 1.0.0                              *
* https://polyformproject.org/licenses/strict/1.0.0                    *
* Made with : Pixel Engine (Godot Engine hard fork)                    *
* https://github.com/WhalesState/godot-pixel-engine                    *
*********************************************************************"""

class_name EditorTheme
extends Theme

## A theme that can be generated from two colors and a hint for dark mode with optional separation for all theme types.
##
## Usage:
##[codeblock]
##var base_color := Color.LIGHT_GRAY
##var accent_color := Color.PURPLE
##var is_dark_theme := false
##var default_separation := 3
##var new_theme := EditorTheme.new(base_color, accent_color, is_dark_theme, default_separation)
##[/codeblock]

## Prevents the theme from updating automatically.
var can_update = false

## The theme base color.
var base_color: Color:
	set(value):
		base_color = value
		update_colors()

## The theme accent color.
var accent_color: Color:
	set(value):
		accent_color = value
		update_colors()

## Changes the generated colors when calling [method update_colors].
var is_dark_theme: bool:
	set(value):
		is_dark_theme = value
		update_colors()

## Changes the default separation for all theme types.
var default_separation : int:
	set(value):
		var sep = clamp(value, 0, 16)
		if sep == default_separation:
			return

		default_separation = sep

		for type in ["BoxContainer", "SplitContainer", "HSeparator", "VSeparator"]:
			set_constant("separation", type, default_separation)

		for type in ["Button", "FoldableContainer", "MenuBar", "TabBar"]:
			set_constant("h_separation", type, default_separation)

		for type in ["GridContainer", "FlowContainer", "ItemList", "PopupMenu", "Tree"]:
			set_constant("h_separation", type, default_separation)
			set_constant("v_separation", type, default_separation)


func _init(_base_color := Color("#1F1B24"), _accent_color := Color("#332940"), _is_dark_theme := true, _default_separation := 4):
	base_color = _base_color
	accent_color = _accent_color
	is_dark_theme = _is_dark_theme
	default_separation = _default_separation
	set_type_variation("GuiBase", "PanelContainer")
	set_stylebox("panel", "GuiBase", create_flat_stylebox(2))
	can_update = true
	update_colors()


## Changes the [Editor] background color.
func set_bg_color(color: Color):
	get_stylebox("panel", "GuiBase").bg_color = color


## Updates all the theme colors if [member can_update] is set to [code]true[/code].
func update_colors():
	if not can_update:
		return
	set_bg_color(base_color)


## Returns a new [StyleBoxFlat].
func create_flat_stylebox(
		content_margin := 0, corner_radius := 0, border_width := 0,
		bg_color := Color(0.6, 0.6, 0.6, 1), border_color := Color(0.8, 0.8, 0.8, 1)
		) -> StyleBoxFlat:
	var flat_style = StyleBoxFlat.new()
	if content_margin != 0:
		flat_style.set_content_margin_all(content_margin)
	if corner_radius != 0:
		flat_style.set_corner_radius_all(corner_radius)
	if border_width != 0:
		flat_style.set_border_width_all(border_width)
	if bg_color != Color(0.6, 0.6, 0.6, 1):
		flat_style.bg_color = bg_color
	if border_color != Color(0.8, 0.8, 0.8, 1):
		flat_style.border_color = border_color
	flat_style.corner_detail = 4
	return flat_style
