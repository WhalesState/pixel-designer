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

class_name Loop
extends SceneTree

## The project Main Loop (Start Point).
##
## Can access [Root] (The main [Window]) on initialize.[br][br]
## [color=yellow]Warning:[/color] Don't use [MainLoop] class directly,
## instead, it can be accessed from any node by using
## [method Node.get_tree] if [method Node.is_inside_tree].
##[codeblock]
##func _enter_tree():
##    var tree: Loop = get_tree()
##[/codeblock]


func _init():
	root.theme = EditorTheme.new()
	# var res := Image.load_svg_from_string("E:/Test/gBot_complete.png")
	# var tex = ImageTexture.new()
	# ResourceSaver.save(res, "user://test.png")