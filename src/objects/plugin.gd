class_name Plugin
extends Object

## The plugin version.
var version := "0.1"

# `PRIVATE` The plugin directory path.
var _path := ""


## Runs when the plugin is enables.
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


## Adds the control to the main screen, and display it's icon in the side menu.
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
	var theme = EditorTheme.get_singleton()
	if not theme:
		print_verbose("Error: Failed to add control: %s and icon: %s to main screen. Editor Theme not found." % [control, icon])
		return
	var button := Button.new()
	control.set_meta("_button", button)
	button.toggle_mode = true
	button.icon = icon
	button.button_group = editor._side_menu_group
	button.tooltip_text = tr(control.name.capitalize())
	if not tooltip.is_empty():
		button.tooltip_text += "\n" + tr(tooltip)
	if main_screen.get_child_count() == 0:
		button.button_pressed = true
	main_screen.add_child(control)
	side_menu.add_child(button)
	button.toggled.connect(func(_pressed: bool):
		if _pressed:
			for child in main_screen.get_children():
				child.visible = child == control
	)


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
	button.queue_free()
	control.get_parent().remove_child(control)
	if is_current:
		if side_menu.get_child_count() > 0:
			var next = side_menu.get_child(0)
			next.button_pressed = true
			next.emit_signal("toggled", true)


## Adds a control to the main menu.
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
	control.tooltip_text = tr(control.name.capitalize())
	if not tooltip.is_empty():
		control.tooltip_text += "\n" + tr(tooltip)
	main_menu.add_child(control, false, internal_mode)


## Remove the control from main menu. [br]
## Use control.free() to manually delete the control from memory.
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


## Adds an icon and converts it's color to the editor theme. [br]
# FIXME: icon queue should be used after this to update the controls property with the icon name after the theme updates.
func add_theme_icon(icon_name: String, svg_string: String):
	var t : EditorTheme = EditorTheme.get_singleton()
	if t.icons.has(icon_name):
		print_verbose("Error: an icon with same name (%s) already exists." % icon_name)
		return
	t.icons[icon_name] = svg_string
	t.update_theme()


## Get the plugin dir path to load or get files within the plugin directory. [br]
## You can use relative paths with preload ie. preload("./my_scene.tscn").
func get_path() -> String:
	return _path
