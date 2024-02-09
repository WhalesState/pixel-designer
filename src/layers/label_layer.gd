@tool
class_name LabelLayer
extends Label

var inspector: VBoxContainer

var font: String:
	set(value):
		if not inspector:
			return
		var fonts: Dictionary = inspector.fonts
		if fonts.has(value):
			font = value
			label_settings.font = fonts[value]
		size = Vector2.ZERO

var font_color := Color.WHITE:
	set(value):
		font_color = value
		label_settings.font_color = font_color

var font_size: int:
	set(value):
		font_size = value
		label_settings.font_size = font_size
		size = Vector2.ZERO

var outline_color := Color.WHITE:
	set(value):
		outline_color = value
		label_settings.outline_color = outline_color

var outline_size: int:
	set(value):
		outline_size = value
		label_settings.outline_size = outline_size

var shadow_visible: bool:
	set(value):
		shadow_visible = value
		label_settings.shadow_color.a = int(shadow_visible)

var shadow_color: Color:
	set(value):
		shadow_color = value
		label_settings.shadow_color = shadow_color
		label_settings.shadow_color.a = int(shadow_visible)

var shadow_size := 1:
	set(value):
		shadow_size = value
		label_settings.shadow_size = shadow_size

var shadow_offset := Vector2.ONE:
	set(value):
		shadow_offset = value
		label_settings.shadow_offset = shadow_offset

var actual_position := Vector2.ZERO:
	set(value):
		actual_position = value
		position = actual_position - pivot_offset


func get_data() -> Dictionary:
	var data := {}
	data["type"] = "LabelLayer"
	data["font"] = font
	data["text"] = text
	data["font_color"] = font_color
	data["font_size"] = font_size
	data["outline_color"] = outline_color
	data["outline_size"] = outline_size
	data["shadow_visible"] = shadow_visible
	data["shadow_color"] = shadow_color
	data["shadow_size"] = shadow_size
	data["shadow_offset"] = shadow_offset
	data["actual_position"] = actual_position
	data["scale"] = scale
	return data


func load_data(data: Dictionary):
	font = data["font"]
	font_color = data["font_color"]
	font_size = data["font_size"]
	outline_color = data["outline_color"]
	outline_size = data["outline_size"]
	shadow_visible = data["shadow_visible"]
	shadow_color = data["shadow_color"]
	shadow_size = data["shadow_size"]
	shadow_offset = data["shadow_offset"]
	actual_position = data["actual_position"]
	scale = data["scale"]
	_resized.call_deferred()


func _init(_inspector: VBoxContainer):
	inspector = _inspector
	text = "TEST"
	label_settings = LabelSettings.new()
	resized.connect(_resized)


func _ready():
	_resized.call_deferred()


## property: [CATEGORY, DISPLAY_NAME, TYPE, DEFAULT_VALUE, HINTS]
func get_properties() -> Dictionary:
	var properties = {}
	properties["font"] = ["Appearance", "Font", FontFile, null, []]
	properties["text"] = ["Appearance", "Text", TYPE_STRING, "", []]
	properties["font_color"] = ["Appearance", "Color", TYPE_COLOR, Color.WHITE, [false]]
	properties["font_size"] = ["Appearance", "Font Size", TYPE_FLOAT, null, [1, 32, 1, true, false]]
	# Outline
	properties["outline_color"] = ["Outline", "Color", TYPE_COLOR, Color.WHITE, [false]]
	properties["outline_size"] = ["Outline", "Size", TYPE_FLOAT, 0, [0, 10, 1, true, false]]
	# Shadow
	properties["shadow_visible"] = ["Shadow", "Visible", TYPE_BOOL, false, []]
	properties["shadow_color"] = ["Shadow", "Color", TYPE_COLOR, Color.BLACK, [false]]
	properties["shadow_size"] = ["Shadow", "Size", TYPE_FLOAT, 1, [0, 10, 1, true, false]]
	properties["shadow_offset"] = ["Shadow", "Offset", TYPE_VECTOR2, Vector2.ONE, [-10, 10, 1, true, true]]
	# Transform
	properties["actual_position"] = ["Transform", "Position", TYPE_VECTOR2, Vector2.ZERO, []]
	properties["scale"] = ["Transform", "Scale", TYPE_VECTOR2, Vector2.ONE, [-9999, 9999, 0.01, true, true]]
	return properties


func _resized():
	size = Vector2.ZERO
