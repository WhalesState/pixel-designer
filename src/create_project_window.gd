@tool
class_name CreateProjectWindow
extends Window

var editor: Editor
var grid: GridContainer
var project_name: LineEdit
var vp_width: SpinBox
var vp_height: SpinBox
var warning: Label
var save_btn: Button


func _init(_editor: Editor):
	editor = _editor
	name = "CreateProjectWindow"
	title = "Create Project"
	visible = false
	wrap_controls = true
	transient = true
	exclusive = true
	always_on_top = true
	size = Vector2(360, 240)
	close_requested.connect(clear_and_hide)
	var scene = preload("res://scene/create_project.tscn").instantiate()
	add_child(scene)
	grid = scene.get_node("%Grid")
	project_name = scene.get_node("%ProjectName")
	vp_width = scene.get_node("%ViewportWidth")
	vp_height = scene.get_node("%ViewportHeight")
	warning = scene.get_node("%Warning")
	save_btn = scene.get_node("%Save")
	scene.get_node("%Cancel").pressed.connect(clear_and_hide)
	project_name.text_changed.connect(_validate_project_name)
	save_btn.pressed.connect(func():
		editor.projects_dir.make_dir(project_name.text)
		editor.project_dir = DirAccess.open(editor.projects_dir.get_current_dir() + "/" + project_name.text)
		editor.project_settings = ConfigFile.new()
		editor.editor_settings.set_value("editor", "recent", project_name.text)
		editor.save_editor_settings()
		if vp_width.visible:
			# Create new project from menu.
			editor.project_settings.set_value("project", "size", Vector2(vp_width.value, vp_height.value))
			editor.save_project_settings()
			editor.reload_project()
		else:
			# Save project as or save for first time.
			editor.save()
		clear_and_hide()
	)
	show_size_settings(true)


func clear_and_hide() -> void:
	project_name.text = ""
	warning.text = "Project name can't be empty!"
	save_btn.disabled = true
	vp_width.value = 16
	vp_height.value = 16
	show_size_settings(false)
	hide()


func show_size_settings(_show: bool):
	for i in range(2, 6):
		grid.get_child(i).visible = _show


func _validate_project_name(_name: String):
	var valid = false
	if _name.is_empty():
		warning.text = "Project name can't be empty!"
	elif not _name.is_valid_filename():
		warning.text = "Project name is invalid!"
	elif editor.projects_dir.get_directories().has(_name):
		warning.text = "Project with same name already exists!"
	else:
		valid = true
		warning.text = "Ready!"
	warning.modulate = Color("4fff78") if valid else Color("ff3434")
	save_btn.disabled = not valid
