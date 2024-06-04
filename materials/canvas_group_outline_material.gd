@tool
class_name CanvasGroupOutlineMaterial
extends ShaderMaterial

static var _shader = preload("res://shaders/canvas_group_outline_shader.gdshader")


func _init():
	shader = _shader


func _validate_property(property):
	if property.name == "shader":
		property.usage = PROPERTY_USAGE_NO_EDITOR
