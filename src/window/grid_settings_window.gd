class_name GridSettingsWindow
extends Window


var image_editor: ImageEditor

var grid_offset_x: SpinBox
var grid_offset_y: SpinBox
var grid_step_x: SpinBox
var grid_step_y: SpinBox
var primary_grid_step_x: SpinBox
var primary_grid_step_y: SpinBox


func _init(_image_editor: ImageEditor):
	image_editor = _image_editor
	name = "GridSettingsWindow"
	title = "Grid Settings"
	visible = false
	wrap_controls = true
	transient = true
	exclusive = true
	always_on_top = true
	size = Vector2(320, 100)
	close_requested.connect(clear_and_hide)
	var scene = preload("res://scene/grid_settings.tscn").instantiate()
	add_child(scene)
	grid_offset_x = scene.get_node("%GridOffsetX")
	grid_offset_x.value_changed.connect(func(value: float):
		image_editor.grid_offset.x = value
	)
	grid_offset_y = scene.get_node("%GridOffsetY")
	grid_offset_y.value_changed.connect(func(value: float):
		image_editor.grid_offset.y = value
	)
	grid_step_x = scene.get_node("%GridStepX")
	grid_step_x.value_changed.connect(func(value: float):
		image_editor.grid_step.x = value
	)
	grid_step_y = scene.get_node("%GridStepY")
	grid_step_y.value_changed.connect(func(value: float):
		image_editor.grid_step.y = value
	)
	primary_grid_step_x = scene.get_node("%PrimaryGridStepX")
	primary_grid_step_x.value_changed.connect(func(value: float):
		image_editor.primary_grid_step.x = floor(value)
	)
	primary_grid_step_y = scene.get_node("%PrimaryGridStepY")
	primary_grid_step_y.value_changed.connect(func(value: float):
		image_editor.primary_grid_step.y = floor(value)
	)
	about_to_popup.connect(_on_about_to_popup)


func _on_about_to_popup():
	grid_offset_x.value = image_editor.grid_offset.x
	grid_offset_y.value = image_editor.grid_offset.y
	grid_step_x.value = image_editor.grid_step.x
	grid_step_y.value = image_editor.grid_step.y
	primary_grid_step_x.value = image_editor.primary_grid_step.x
	primary_grid_step_y.value = image_editor.primary_grid_step.y


func clear_and_hide() -> void:
	var editor_settings = ED.editor_settings
	editor_settings.set_value("editor", "grid_offset", image_editor.grid_offset)
	editor_settings.set_value("editor", "grid_step", image_editor.grid_step)
	editor_settings.set_value("editor", "primary_grid_step", image_editor.primary_grid_step)
	ED.save_editor_settings()
	hide()
