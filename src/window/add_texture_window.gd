class_name AddTextureWindow
extends Window

signal create_texture(type: String)

var editor: ImageEditor


func _init(_editor: ImageEditor):
	editor = _editor
	name = "AddTextureWindow"
	title = "Add Texture"
	visible = false
	wrap_controls = true
	transient = true
	exclusive = true
	always_on_top = true
	size = Vector2(360, 240)
	close_requested.connect(clear_and_hide)
	var scene = preload("res://scene/add_texture.tscn").instantiate()
	for child in scene.get_node("%VBox").get_children():
		child.pressed.connect(emit_signal.bind("create_texture", child.text))
	add_child(scene)


func clear_and_hide() -> void:
	hide()
