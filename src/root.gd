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

class_name Root
extends Window

## The program [Window] (First Node in the SceneTree).
##
## [color=yellow]Warning:[/color] Don't use [Root] class directly,
## instead, it can be accessed from any node by using
## [method SceneTree.get_root] if [method Node.is_inside_tree].
##[codeblock]
##func _enter_tree():
##    var root: Root = get_tree().get_root()
##[/codeblock]
