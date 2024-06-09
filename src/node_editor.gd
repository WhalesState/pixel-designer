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


var root_container := SubViewportContainer.new()
var root := SubViewport.new()
var viewport := SubViewport.new()


func _init():
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
