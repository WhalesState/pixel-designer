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

extends Control

## The Editor control node.
##
## [color=yellow]Warning:[/color] Don't use [Editor] class directly,
## instead, it can be accessed from any node by using if [method Node.is_inside_tree].
##[codeblock]
##func _enter_tree():
##    print(Editor.gui_base)
##[/codeblock]

enum Base {
	TOP_LEFT_CONTAINER = 0,
	TOP_RIGHT_CONTAINER = 1,
	TOP_LEFT_DOCK = 2,
	BOTTOM_LEFT_DOCK = 3,
	BOTTOM_DOCK = 4,
	TOP_RIGHT_DOCK = 5,
	BOTTOM_RIGHT_DOCK = 6,
}

## The base panel container which contains all the editor GUI.
var gui_base := PanelContainer.new()
var main_vbox := VBoxContainer.new()
var top_left_hbox := HBoxContainer.new()
var _main_screen_buttons := HBoxContainer.new()
var top_right_hbox := HBoxContainer.new()


func _init():
	gui_base.name = "GuiBase"
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	gui_base.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	gui_base.theme_type_variation = "GuiBase"
	add_child(gui_base)
	main_vbox.name = "MainVBox"
	gui_base.add_child(main_vbox)
	var top_menu_hbox := HBoxContainer.new()
	top_menu_hbox.name = "TopMenuHBox"
	top_menu_hbox.add_theme_constant_override("separation", 0)
	main_vbox.add_child(top_menu_hbox)
	top_left_hbox.name = "TopLeftHBox"
	top_menu_hbox.add_child(top_left_hbox)
	top_menu_hbox.add_spacer(false)
	_main_screen_buttons.name = "MainScreenButtons"
	top_menu_hbox.add_child(_main_screen_buttons)
	top_menu_hbox.add_spacer(false)
	top_right_hbox.name = "TopRightHBox"
	top_menu_hbox.add_child(top_right_hbox)


func _ready():
	get_tree().get_root().min_size = gui_base.get_minimum_size()


## Adds a control node to the editor.
func add_control(control: Control, base: Base):
	var container = get_container(base)
	if container:
		container.add_child(control)


## Removes a control node from the editor.
func remove_control(control: Control, base: Base):
	var container = get_container(base)
	if container:
		container.remove_child(control)


func get_container(base: Base) -> Control:
	match base:
		Base.TOP_LEFT_CONTAINER:
			return top_left_hbox
		Base.TOP_RIGHT_CONTAINER:
			return top_right_hbox
		Base.TOP_LEFT_DOCK:
			return null
		Base.BOTTOM_LEFT_DOCK:
			return null
		Base.BOTTOM_DOCK:
			return null
		Base.TOP_RIGHT_DOCK:
			return null
		Base.BOTTOM_RIGHT_DOCK:
			return null
		_:
			return null
