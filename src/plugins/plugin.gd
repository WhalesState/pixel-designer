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

class_name Plugin
extends Object

## This is the base of all editor plugins, just to make sure your plugin.gd file has load_plugin() and unload_plugin().
##
## Why is it needed?[br]
## If you want to share your plugin with PixelDesigner users, you can easily share the .pck file in user data folder and they can import it easily from any released version.[br]
## Your plugin files will always be packed when you run the program from the editor, and you can find the packed files by looking at the "user://plugins/" folder in debug builds.
## Or from the Project menu "Project -> Open User Data Folder" and navigate to plugins folder.[br]
## For usage example, see "plugins/PixelDesigner.Test/plugin.gd".[br]
## Plugin folders should have a unique name ie. "YourName.PluginName-1.0.0", else, the plugin files will replace the existing ones when it's loaded.[br]
## The contents of the "res://plugins/" should not be exported when exporting the program.[br]
## And they will be loaded when the plugin is enabled into "res://loaded_plugins/PluginName/".[br]
## Plugins are loaded when the editor is ready and the plugin is enabled, and unloaded when the editor is closed or the plugin is disabled.[br]


# Called by [Editor] when it's ready or when plugin is enabled.
func load_plugin():
	pass


## Called by [Editor] when it's exiting tree or when plugin is disabled.
func unload_plugin():
	pass
