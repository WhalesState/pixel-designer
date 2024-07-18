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

class_name EditorSettingsWindow
extends Window

var editor: Editor
var plugins_vbox: VBoxContainer


func _init(_editor):
	editor = _editor
	name = "EditorSettingsWindow"
	title = "Editor Settings"
	visible = false
	wrap_controls = true
	transient = true
	exclusive = true
	always_on_top = true
	size = Vector2(640, 480)
	close_requested.connect(clear_and_hide)
	var scene = preload("res://scene/editor_settings.tscn").instantiate()
	add_child(scene)
	plugins_vbox = scene.get_node("%Plugins")
	about_to_popup.connect(func():
		update_settings()
	)


func update_settings():
	for node in plugins_vbox.get_children():
		plugins_vbox.remove_child(node)
		node.queue_free()
	for plugin in editor.plugin_list.keys():
		var plugin_button = CheckButton.new()
		plugin_button.text = plugin
		plugin_button.button_pressed = editor.is_plugin_enabled(plugin)
		plugin_button.toggled.connect(func(enabled: bool):
			editor._set_plugin_enabled(plugin, enabled)
		)
		plugins_vbox.add_child(plugin_button)


func clear_and_hide() -> void:
	hide()
