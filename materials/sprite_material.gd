@tool
class_name SpriteMaterial
extends ShaderMaterial

static var _shader = preload("res://shaders/sprite_shader.gdshader")


func _init():
	shader = _shader


func _validate_property(property):
	if property.name == "shader":
		property.usage = PROPERTY_USAGE_NO_EDITOR
