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

class_name NodeEditor
extends ControlViewport


var editor: Editor
var root_container := SubViewportContainer.new()
var root := SubViewport.new()
var viewport := SubViewport.new()


func _init(_editor: Editor):
	editor = _editor
	name = "NodeEditor"
	var svp := SubViewportContainer.new()
	svp.set_anchors_and_offsets_preset(PRESET_FULL_RECT)
	svp.stretch = true
	add_child(svp)
	svp.add_child(viewport)
	view_transform_changed.connect(func(transform: Transform2D):
		viewport.set_canvas_transform(transform)
	)
	root_container.size = view_size
	root_container.stretch = true
	viewport.add_child(root_container)
	root_container.add_child(root)
	var spr = Sprite2D.new()
	spr.texture = load("./icon.svg")
	root.add_child(spr)
	# Load settings.
	var editor_settings = editor.editor_settings
	show_grid = editor_settings.get_value("editor", "show_grid", true)
	show_rulers = editor_settings.get_value("editor", "show_rulers", true)
	show_guides = editor_settings.get_value("editor", "show_guides", true)
	grid_offset = editor_settings.get_value("editor", "grid_offset", Vector2.ZERO)
	grid_step = editor_settings.get_value("editor", "grid_step", Vector2(16, 16))
	primary_grid_step = editor_settings.get_value("editor", "primary_grid_step", Vector2i(8, 8))
	# Guides.
	var project_settings = editor.project_settings
	vguides = project_settings.get_value("project", "vguides", PackedInt32Array())
	hguides = project_settings.get_value("project", "hguides", PackedInt32Array())
	guides_changed.connect(func():
		project_settings.set_value("project", "hguides", hguides)
		project_settings.set_value("project", "vguides", vguides)
		editor.save_project_settings()
	)
	# Options Menu.
	var options_menu := MenuButton.new()
	options_menu.icon = preload("res://icons/options.svg")
	var popup := options_menu.get_popup()
	popup.add_check_item("Show Grid", 0)
	popup.set_item_checked(0, show_grid)
	var grid_settings_window = GridSettingsWindow.new(self)
	add_child(grid_settings_window)
	popup.add_item("Grid Settings", 1)
	popup.add_check_item("Show Rulers", 2)
	popup.set_item_checked(2, show_rulers)
	popup.add_check_item("Show Guides", 3)
	popup.set_item_checked(3, show_guides)
	popup.add_item("Clear Guides", 4)
	popup.id_pressed.connect(func(id: int):
		if id == 0:
			popup.set_item_checked(0, not show_grid)
			show_grid = popup.is_item_checked(0)
			editor_settings.set_value("editor", "show_grid", show_grid)
			editor.save_editor_settings()
		elif id == 1:
			grid_settings_window.popup_centered()
		elif id == 2:
			popup.set_item_checked(2, not show_rulers)
			show_rulers = popup.is_item_checked(2)
			editor_settings.set_value("editor", "show_rulers", show_rulers)
			editor.save_editor_settings()
		elif id == 3:
			popup.set_item_checked(3, not show_guides)
			show_guides = popup.is_item_checked(3)
			editor_settings.set_value("editor", "show_guides", show_guides)
			editor.save_editor_settings()
		elif id == 4:
			clear_guides()
	)
	get_controls_container().add_child(options_menu, false, INTERNAL_MODE_BACK)
