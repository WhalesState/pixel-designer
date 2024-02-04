@tool
class_name LabelLayer
extends Label

var actual_position := Vector2.ZERO:
	set(value):
		actual_position = value
		position = actual_position - pivot_offset


func get_data() -> Dictionary:
	var data := {}
	data["type"] = "LabelLayer"
	data["actual_position"] = actual_position
	data["scale"] = scale
	return data


func load_data(data: Dictionary):
	actual_position = data["actual_position"]
	scale = data["scale"]


func _init():
	name = "LabelLayer"
	text = "TEST"


## property: [CATEGORY, DISPLAY_NAME, TYPE, DEFAULT_VALUE, HINTS]
func get_properties() -> Dictionary:
	var properties = {}
	properties["actual_position"] = ["Transform", "Position", TYPE_VECTOR2, Vector2.ZERO]
	properties["scale"] = ["Transform", "Scale", TYPE_VECTOR2, Vector2.ONE, [-9999, 9999, 0.01, true, true]]
	return properties
