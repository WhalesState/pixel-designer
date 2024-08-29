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


## Adds the [param control] to the main screen, and displays it's icon in the side menu. [br]
## The tooltip of the generated button is your control.name.capitalize() MyControl -> My Control, see [method String.capitalize]. [br]
## Optionally you can pass a tooltip text to be added in a new line after the control name. [br]
## Each of The capitalized name of your control and the optional tooltip will be translated separetly if their translation is available.
func add_control_to_main_screen(control: Control, icon := "", tooltip := ""):
	if not control:
		print_verbose("Error: Failed to add control: %s to main screen." % control)
		return
	var editor := Editor.get_singleton()
	if not editor:
		print_verbose("Error: Failed to add control: %s to main screen. Editor not found." % control)
		return
	var main_screen := editor._main_screen
	var side_menu := editor._side_menu
	var theme = EditorTheme.get_singleton()
	if icon.is_empty() or not theme.icons.has(icon):
		print_verbose("Warning: Your control: %s doesn't have a valid icon, the default Plugin icon was set instead." % control)
		icon = "Plugin"
	var button := Button.new()
	button.set_meta("_icon", icon)
	control.set_meta("_button", button)
	button.toggle_mode = true
	theme.add_to_icon_queue(button, "icon", icon)
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


## Removes the [param control] from the main screen and frees it's button only.
## Use [method Object.free] to manually delete your control from memory.
func remove_control_from_main_screen(control: Control):
	if not control:
		print_verbose("Error: Failed to remove control: %s from main screen." % control)
		return
	var editor := Editor.get_singleton()
	if not editor:
		print_verbose("Error: Failed to remove control: %s from main screen. Editor not found." % control)
		return
	var side_menu := editor._side_menu
	var button = control.get_meta("_button")
	if not button:
		print_verbose("Error: Control: %s has no button. Failed to remove it from main screen." % control)
		return
	EditorTheme.get_singleton().remove_from_icon_queue(button, "icon", button.get_meta("_icon"))
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


## Adds the [param control] to the main menu. [br]
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
	editor._main_menu.add_child(control, false, internal_mode)
	control.set_meta("_tooltip_name", control.name.capitalize())
	control.set_meta("_tooltip", tooltip)
	update_tooltip(control)
	translation_changed.connect(update_tooltip.bind(control))
	Actions.get_singleton().action_map_changed.connect(update_tooltip.bind(control))


## Removes the [param control] from main menu. [br]
## Use [method Object.free] to manually delete your control from memory.
func remove_control_from_main_menu(control: Control):
	if not control:
		print_verbose("Error: Failed to remove control: %s from main menu." % control)
		return
	var editor := Editor.get_singleton()
	if not editor:
		print_verbose("Error: Failed to remove control: %s from main menu. Editor not found." % control)
		return
	control.get_parent().remove_child(control)
	translation_changed.disconnect(update_tooltip.bind(control))
	Actions.get_singleton().action_map_changed.disconnect(update_tooltip.bind(control))


## Adds the [param control] to the editor settings window and diplays it's icon and name in the side menu. [br]
## The tooltip of the generated button is your control.name.capitalize() MyControl -> My Control, see [method String.capitalize]. [br]
## Optionally you can pass a tooltip text to be added in a new line after the control name. [br]
## Each of The capitalized name of your control and the optional tooltip will be translated separetly if their translation is available.
func add_control_to_settings(control: Control, icon := "", tooltip := ""):
	if not control:
		print_verbose("Error: Failed to add control: %s to settings window." % control)
		return
	var settings := Settings.get_singleton()
	var main_screen := settings._main_screen
	var side_menu := settings._side_menu
	var theme = EditorTheme.get_singleton()
	if icon.is_empty() or not theme.icons.has(icon):
		print_verbose("Warning: Your control: %s doesn't have a valid icon, the default Settings icon will be used instead." % control)
		icon = "Settings"
	var button := Button.new()
	button.set_meta("_icon", icon)
	control.set_meta("_button", button)
	button.toggle_mode = true
	button.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	button.alignment = HORIZONTAL_ALIGNMENT_CENTER
	button.icon_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	button.add_theme_constant_override("h_separation", 0)
	theme.add_to_icon_queue(button, "icon", icon)
	button.button_group = settings._side_menu_group
	if main_screen.get_child_count() == 0:
		button.button_pressed = true
	main_screen.add_child(control)
	side_menu.add_child(button)
	button.toggled.connect(func(_pressed: bool):
		if _pressed:
			for child in main_screen.get_children():
				child.visible = child == control
	)
	button.set_meta("_text", control.name.capitalize())
	button.set_meta("_tooltip_name", control.name.capitalize())
	button.set_meta("_tooltip", tooltip)
	update_tooltip(button)
	translation_changed.connect(update_tooltip.bind(button))


func remove_control_from_settings(control: Control):
	if not control:
		print_verbose("Error: Failed to remove control: %s from settings window." % control)
		return
	var settings := Settings.get_singleton()
	var side_menu := settings._side_menu
	var button = control.get_meta("_button")
	if not button:
		print_verbose("Error: Control: %s has no button. Failed to remove it from main screen." % control)
		return
	EditorTheme.get_singleton().remove_from_icon_queue(button, "icon", button.get_meta("_icon"))
	var is_current = button.button_pressed
	side_menu.remove_child(button)
	control.get_parent().remove_child(control)
	var callable = button.toggled.get_connections()[0]["callable"]
	if callable:
		button.toggled.disconnect(callable)
	translation_changed.disconnect(update_tooltip.bind(button))
	button.free()
	if is_current:
		if side_menu.get_child_count() > 0:
			var next = side_menu.get_child(0)
			next.button_pressed = true
			next.emit_signal("toggled", true)
			for _button in side_menu.get_children():
				update_tooltip(_button)


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
	var text = control.get_meta("_text", "")
	if not text.is_empty():
		control.text += text


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


func get_theme_icon(icon_name: String) -> Texture2D:
	var t : EditorTheme = EditorTheme.get_singleton()
	if not t.icons.has(icon_name):
		print_verbose("Error: an icon with name (%s) does not exist." % icon_name)
		return null
	return t.get_icon(icon_name, "Icons")


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
