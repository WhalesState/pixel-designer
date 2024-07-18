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

class_name ProjectSettingsWindow
extends Window

var editor: Editor
var vp_width: SpinBox
var vp_height: SpinBox
var snap_transforms: CheckButton
var snap_vetrices: CheckButton
var filter: OptionButton


func _init(_editor):
	editor = _editor
	name = "ProjectSettingsWindow"
	title = "Project Settings"
	visible = false
	wrap_controls = true
	transient = true
	exclusive = true
	always_on_top = true
	size = Vector2(640, 480)
	close_requested.connect(clear_and_hide)
	var scene = preload("res://scene/project_settings.tscn").instantiate()
	add_child(scene)
	vp_width = scene.get_node("%ViewportWidth")
	vp_width.value_changed.connect(func(value: float):
		editor.image_editor.root_container.size.x = value
		editor.image_editor.view_size.x = value
		editor.project_settings.set_value("project", "view_width", value)
		editor.save_project_settings()
	)
	vp_height = scene.get_node("%ViewportHeight")
	vp_height.value_changed.connect(func(value: float):
		editor.image_editor.root_container.size.y = value
		editor.image_editor.view_size.y = value
		editor.project_settings.set_value("project", "view_height", value)
		editor.save_project_settings()
	)
	snap_transforms = scene.get_node("%SnapTransforms")
	snap_transforms.toggled.connect(func(enabled: bool):
		editor.image_editor.root.snap_2d_transforms_to_pixel = enabled
		editor.project_settings.set_value("project", "snap_2d_transforms_to_pixel", enabled)
		editor.save_project_settings()
	)
	snap_vetrices = scene.get_node("%SnapVertices")
	snap_vetrices.toggled.connect(func(enabled: bool):
		editor.image_editor.root.snap_2d_vertices_to_pixel = enabled
		editor.project_settings.set_value("project", "snap_2d_vertices_to_pixel", enabled)
		editor.save_project_settings()
	)
	filter = scene.get_node("%Filter")
	filter.get_popup().id_pressed.connect(func(id: int):
		var filters = [Viewport.DEFAULT_CANVAS_ITEM_TEXTURE_FILTER_NEAREST, Viewport.DEFAULT_CANVAS_ITEM_TEXTURE_FILTER_LINEAR]
		editor.image_editor.root.canvas_item_default_texture_filter = filters[id]
		editor.project_settings.set_value("project", "filter", filters[id])
		editor.save_project_settings()
	)
	about_to_popup.connect(func():
		update_settings()
	)


func update_settings():
	if not editor.image_editor:
		return
	var vp_size := editor.get_viewport_size()
	vp_width.value = vp_size.x
	vp_height.value = vp_size.y
	snap_transforms.button_pressed = editor.image_editor.root.snap_2d_transforms_to_pixel
	snap_vetrices.button_pressed = editor.image_editor.root.snap_2d_vertices_to_pixel
	filter.selected = editor.image_editor.root.canvas_item_default_texture_filter


func clear_and_hide() -> void:
	hide()
