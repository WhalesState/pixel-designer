class_name Plugin
extends Object

## Emits when translation changes.
signal translation_changed

## [b]PRIVATE[/b] The plugin directory path.
var _path := ""


## Runs when the plugin is enabled.
func load_plugin():
	pass


## Runs when the plugin is disabled.
func unload_plugin():
	pass


## Internal plugins can't be disabled and loads first!
func is_internal() -> bool:
	return false


## Plugin information.
func get_plugin_info() -> String:
	return ""


## Plugin version.
func get_plugin_version() -> String:
	return "0.0.0"


## Adds the control to the main screen, and display it's icon in the side menu. [br]
## The tooltip of the generated button is your control.name.capitalize() MyControl -> My Control, see [method String.capitalize]. [br]
## Optionally you can pass a tooltip text to be added in a new line after the control name. [br]
## Each of The capitalized name of your control and the optional tooltip will be translated separetly if their translation is available.
func add_control_to_main_screen(control: Control, icon: Texture2D, tooltip := ""):
	if not control or not icon:
		print_verbose("Error: Failed to add control: %s and icon: %s to main screen." % [control, icon])
		return
	var editor := Editor.get_singleton()
	if not editor:
		print_verbose("Error: Failed to add control: %s and icon: %s to main screen. Editor not found." % [control, icon])
		return
	var main_screen := editor._main_screen
	if not main_screen:
		print_verbose("Error: Failed to add control: %s and icon: %s to main screen. Main screen not found." % [control, icon])
		return
	var side_menu := editor._side_menu
	if not side_menu:
		print_verbose("Error: Failed to add control: %s and icon: %s to main screen. Side menu not found." % [control, icon])
		return
	var button := Button.new()
	control.set_meta("_button", button)
	button.toggle_mode = true
	button.icon = icon
	button.button_group = editor._side_menu_group
	if main_screen.get_child_count() == 0:
		button.button_pressed = true
	main_screen.add_child(control)
	side_menu.add_child(button)
	button.toggled.connect(func(_pressed: bool):
		if _pressed:
			for child in main_screen.get_children():
				child.visible = child == control
	)
	button.set_meta("_tooltip_name", control.name.capitalize())
	button.set_meta("_tooltip", tooltip)
	button.set_meta("_action", "ED_SCREEN_%s" % (button.get_index() + 1))
	update_tooltip(button)
	translation_changed.connect(update_tooltip.bind(button))
	Actions.get_singleton().action_map_changed.connect(update_tooltip.bind(button))


## Removes a control from the main screen and frees it's button only.
## Use [method Object.free] to manually delete your control from memory.
func remove_control_from_main_screen(control: Control):
	if not control:
		print_verbose("Error: Failed to remove control: %s from main screen." % control)
		return
	var editor := Editor.get_singleton()
	if not editor:
		print_verbose("Error: Failed to remove control: %s from main screen. Editor not found." % control)
		return
	var main_screen := editor._main_screen
	if not main_screen:
		print_verbose("Error: Failed to remove control: %s from main screen. Main screen not found." % control)
		return
	var side_menu := editor._side_menu
	if not side_menu:
		print_verbose("Error: Failed to remove control: %s from main screen. Side menu not found." % control)
		return
	var button = control.get_meta("_button")
	if not button:
		print_verbose("Error: Control: %s has no button. Failed to remove it from main screen." % control)
		return
	var is_current = button.button_pressed
	side_menu.remove_child(button)
	control.get_parent().remove_child(control)
	var callable = button.toggled.get_connections()[0]["callable"]
	if callable:
		button.toggled.disconnect(callable)
	translation_changed.disconnect(update_tooltip.bind(button))
	Actions.get_singleton().action_map_changed.disconnect(update_tooltip.bind(button))
	button.free()
	if is_current:
		if side_menu.get_child_count() > 0:
			var next = side_menu.get_child(0)
			next.button_pressed = true
			next.emit_signal("toggled", true)
			for _button in side_menu.get_children():
				update_tooltip(_button)


## Adds the control to the main menu. [br]
## The tooltip of the generated button is your control.name.capitalize() MyControl -> My Control, see [method String.capitalize]. [br]
## Optionally you can pass a tooltip text to be added in a new line after the control name. [br]
## Each of The capitalized name of your control and the optional tooltip will be translated separetly if their translation is available. [br]
## If your control has children that prevents it from showing the tooltip, you should handle the tooltip manually in your controls. [br]
## Example: [code] my_button.tooltip_text = tr(my_button.name.capitalize()) + "\n" + tr("Prints 'Hello World!' to the console.") [/code]
func add_control_to_main_menu(control: Control, tooltip := "", internal_mode := Node.INTERNAL_MODE_DISABLED):
	if not control:
		print_verbose("Error: Failed to add control: %s to main menu." % control)
		return
	var editor := Editor.get_singleton()
	if not editor:
		print_verbose("Error: Failed to add control: %s to main menu. Editor not found." % control)
		return
	var main_menu = editor._main_menu
	if not main_menu:
		print_verbose("Error: Failed to add control: %s to main menu. Main menu not found." % control)
		return
	main_menu.add_child(control, false, internal_mode)
	control.set_meta("_tooltip_name", control.name.capitalize())
	control.set_meta("_tooltip", tooltip)
	update_tooltip(control)
	translation_changed.connect(update_tooltip.bind(control))
	Actions.get_singleton().action_map_changed.connect(update_tooltip.bind(control))


## Remove the control from main menu. [br]
## Use [method Object.free] to manually delete your control from memory.
func remove_control_from_main_menu(control: Control):
	if not control:
		print_verbose("Error: Failed to remove control: %s from main menu." % control)
		return
	var editor := Editor.get_singleton()
	if not editor:
		print_verbose("Error: Failed to remove control: %s from main menu. Editor not found." % control)
		return
	var main_menu = editor._main_menu
	if not main_menu:
		print_verbose("Error: Failed to remove control: %s from main menu. Main menu not found." % control)
		return
	main_menu.remove_child(control)
	translation_changed.disconnect(update_tooltip.bind(control))
	Actions.get_singleton().action_map_changed.disconnect(update_tooltip.bind(control))


func update_tooltip(control: Control):
	if not control:
		print_verbose("Error: Failed to update tooltip of control: %s." % control)
		return
	control.tooltip_text = tr(control.get_meta("_tooltip_name"))
	var action = control.get_meta("_action", "")
	if not action.is_empty():
		var actions := Actions.get_singleton()._actions
		if actions.has(action) and actions[action] != KEY_NONE:
			control.tooltip_text += " (%s)" % OS.get_keycode_string(actions[action])
	var tooltip = control.get_meta("_tooltip", "")
	if not tooltip.is_empty():
		control.tooltip_text += "\n" + tr(tooltip)


## Adds an icon and converts it's color to the editor theme. [br]
## See [method EditorTheme.add_to_icon_queue].
## [codeblock]
## var rect = TextureRect.new()
## var icon_file = FileAccess.open(get_path() + "/icons/my_icon.svg", FileAccess.READ)
## if icon_file:
##     add_theme_icon("MyIcon", icon_file.get_as_text())
##     EditorTheme.get_singleton().add_to_icon_queue(rect, "texture", "MyIcon")
##     icon_file.close()
## [/codeblock]
func add_theme_icon(icon_name: String, svg_string: String):
	var t : EditorTheme = EditorTheme.get_singleton()
	if t.icons.has(icon_name):
		print_verbose("Error: an icon with same name (%s) already exists." % icon_name)
		return
	t.icons[icon_name] = svg_string
	t.update_theme()


## Get the plugin dir path to load or get files within the plugin directory. [br]
## Example: [code]load(get_path() + "/src/my_script.gd")[/code] [br]
## You can use relative paths with preload ie. [code]preload("./my_scene.tscn")[/code].
func get_path() -> String:
	return _path


## Return [code]true[/code] if the plugin can exit, or false if the plugin should handle the exit manually. ie. unsaved changes. [br]
## Example:
## [codeblock]
## func can_exit() -> bool:
##     var confirm = ConfirmationDialog.new()
##     Editor.get_singleton().add_child(confirm)
##     confirm.dialog_text = tr("<Plugin Name> has unsaved changes!")
##     confirm.ok_button_text = "Save and exit"
##     confirm.popup_centered()
##     confirm.confirmed.connect(func():
##         # Save your changes and call quit() manually.
##         Main.get_singleton().quit()
##     )
##     return false # To prevent the app from closing
## [/codeblock]
func can_exit() -> bool:
	return true
