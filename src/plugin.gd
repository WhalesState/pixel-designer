class_name Plugin
extends Object

## Base editor containers.
enum CONTAINER {
	TOP_LEFT = 0,
	TOP_CENTER = 1,
	TOP_RIGHT = 2,
	TOP_LEFT_DOCK = 3,
	BOTTOM_LEFT_DOCK = 4,
	CENTER_DOCK = 5,
	BOTTOM_DOCK = 6,
	TOP_RIGHT_DOCK = 7,
	BOTTOM_RIGHT_DOCK = 8,
}

## The plugin version.
var version := "0.1"

# The plugin directory path.
var _path := ""


## Runs when the plugin is enables.
func load_plugin():
	pass


## Runs when the plugin is disabled.
func unload_plugin():
	pass


## Internal plugins can't be disabled!
func is_internal() -> bool:
	return false


## Adds a control as a child of the base container.
## You can optionally pass an editor theme icon name.
func add_control_to_editor(control: Control, base: CONTAINER, icon := ""):
	var container = _get_editor_container(base)
	if not container:
		return
	if not icon.is_empty():
		control.set_meta("icon", icon)
	if container.has_node(str(control.name)):
		var _idx = 1
		while container.has_node(str(control.name) + str(_idx)):
			_idx += 1
		control.name = str(control.name) + str(_idx)
	container.add_child(control)


## Remove the control from the editor container.
## Use control.free() to manually delete the control from memory.
func remove_control_from_editor(control: Control):
	control.get_parent().remove_child(control)


# Gets a container from the editor ui.
func _get_editor_container(base: CONTAINER) -> Control:
	const containers := [
		"top_left_container", "top_center_container", "top_right_container",
		"top_left_dock", "bottom_left_dock", "center_dock",
		"bottom_dock", "top_right_dock", "bottom_right_dock",
	]
	return Editor.get_singleton().get(containers[base])


## Adds an icon and converts it's color to the editor theme.
## Use EditorTheme.icon(icon_name) to get the icon texture.
func add_theme_icon(icon_name: String, svg_string: String):
	var t : EditorTheme = EditorTheme.get_singleton()
	if t.icons.has(icon_name):
		print("Error: an icon with same name (%s) already exists." % icon_name)
		return
	t.icons[icon_name] = svg_string
	t._update_theme()


## Get the plugin dir path to load or get files within the plugin directory.
## You can use relative paths with preload ie. preload("./my_scene.tscn").
func get_path() -> String:
	return _path
