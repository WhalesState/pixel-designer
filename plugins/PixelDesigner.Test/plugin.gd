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

extends Plugin

## Use load_plugin() to initialize your plugin scene, and unload_plugin() to free it.
var rect: TextureRect


func load_plugin():
	print("Test plugin loaded")
	rect = TextureRect.new()
	rect.texture = preload("./icons/icon.svg")
	rect.name = "TEST PLUGIN"
	Editor.add_control(rect, Editor.Base.TOP_LEFT_DOCK)


func unload_plugin():
	print("Test plugin unloaded")
	# The editor never frees your nodes, it just removes them from the scene tree.
	Editor.remove_control(rect, Editor.Base.TOP_LEFT_DOCK)
	rect.queue_free()
