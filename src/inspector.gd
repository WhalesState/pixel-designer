@tool
extends VBoxContainer

enum {
	CATEGORY,
	DISPLAY_NAME,
	TYPE,
	DEFAULT_VALUE,
	HINTS,
}

var selected = null
var label := InspectorLabel.new()
var fonts := {}


func _ready():
	get_parent().get_parent().add_child.call_deferred(label, true, INTERNAL_MODE_FRONT)


## property: [CATEGORY, DISPLAY_NAME, TYPE, DEFAULT_VALUE, HINTS]
func load_properties(node: Node):
	var properties := {}
	properties = node.get_properties()
	if properties.keys().size() == 0:
		return
	clear()
	label.text = node.name
	selected = node
	for property in properties.keys():
		var data = properties[property]
		add_property(data[CATEGORY], data[DISPLAY_NAME], data[TYPE], node, property, data[DEFAULT_VALUE], data[HINTS])


func add_property(property_category: String, property_name: String, property_type: Variant, property_owner: Node, property: String, default_value = null, hints := []):
	var category: Category
	if not property_category.is_empty():
		category = get_node_or_null(property_category)
		if not category:
			category = Category.new(property_category)
			category.name = property_category
			add_child(category)
	var hbox := HBoxContainer.new()
	hbox.custom_minimum_size.y = 24
	if category:
		category.get_child(0).add_child(hbox)
	else:
		add_child(hbox, false, INTERNAL_MODE_FRONT)
	var name_hbox := NameHBox.new(property_name)
	hbox.add_child(name_hbox)
	var node
	var reset_button = null
	if default_value != null:
		reset_button = ResetButton.new(default_value)
		name_hbox.add_child(reset_button)
	match property_type:
		TYPE_STRING:
			node = LineEdit.new()
			node.text = property_owner.get(property)
			if reset_button:
				reset_button.visible = default_value != node.text
			node.text_changed.connect(_on_property_changed.bind(property_owner, property, reset_button))
		TYPE_COLOR:
			node = ColorPickerButton.new()
			node.color = property_owner.get(property)
			if reset_button:
				reset_button.visible = default_value != node.color
			node.edit_alpha = hints[0]
			node.color_changed.connect(_on_property_changed.bind(property_owner, property, reset_button))
		TYPE_FLOAT, TYPE_INT:
			if hints.is_empty():
				hints = [-1000, 1000, 1.0, true, true]
			node = SpinBoxSlider.new(SpinBoxSlider.SUFFIX_PIXEL, true, hints[0], hints[1], hints[2], hints[3], hints[4])
			node.value = property_owner.get(property)
			if reset_button:
				reset_button.visible = default_value != node.value
			node.value_changed.connect(_on_property_changed.bind(property_owner, property, reset_button))
		FontFile:
			node = FontOptions.new(property_owner, property, self)
		TYPE_BOOL:
			node = CheckBox.new()
			node.flat = true
			node.text = "On"
			node.button_pressed = property_owner.get(property)
			if reset_button:
				reset_button.visible = default_value != node.button_pressed
			node.toggled.connect(_on_property_changed.bind(property_owner, property, reset_button))
		TYPE_VECTOR2:
			if hints.is_empty():
				hints = [-9999,9999,1.0, true, true]
			node = VBoxContainer.new()
			var x_spinbox = SpinBoxSlider.new(SpinBoxSlider.SUFFIX_NONE, false, hints[0], hints[1], hints[2], hints[3], hints[4])
			x_spinbox.value = property_owner.get(property).x
			node.add_child(x_spinbox)
			var y_spinbox = SpinBoxSlider.new(SpinBoxSlider.SUFFIX_NONE, false, hints[0], hints[1], hints[2], hints[3], hints[4])
			y_spinbox.value = property_owner.get(property).y
			node.add_child(y_spinbox)
			if reset_button:
				reset_button.visible = default_value != Vector2(x_spinbox.value, y_spinbox.value)
			x_spinbox.value_changed.connect(_on_vec2_property_changed.bind(x_spinbox, y_spinbox, property_owner, property, reset_button))
			y_spinbox.value_changed.connect(_on_vec2_property_changed.bind(x_spinbox, y_spinbox, property_owner, property, reset_button))
	if reset_button:
		reset_button.pressed.connect(_on_reset_property_pressed.bind(node, default_value))
	hbox.add_child(node)
	node.size_flags_horizontal = SIZE_EXPAND_FILL


func clear():
	label.text = ""
	selected = null
	for child in get_children():
		remove_child(child)
		child.queue_free()


func _on_property_changed(value: Variant, property_owner: Node, property: String, reset_button: Button):
	property_owner.set(property, value)
	if reset_button:
		reset_button.visible = reset_button.get_meta("default_value") != value


func _on_vec2_property_changed(_value: float, x_value_owner: Range, y_value_owner: Range, property_owner: Node, property: String, reset_button = null):
	var value = Vector2(x_value_owner.value, y_value_owner.value)
	property_owner.set(property, value)
	if reset_button:
		reset_button.visible = reset_button.get_meta("default_value") != value


func _on_reset_property_pressed(node: Node, value: Variant):
	match typeof(value):
		TYPE_FLOAT, TYPE_INT:
			node.value = value
		TYPE_BOOL:
			node.button_pressed = value
		TYPE_COLOR:
			node.color = value
		TYPE_VECTOR2:
			node.get_child(0).value = value.x
			node.get_child(1).value = value.y
		TYPE_STRING:
			node.text = value
			node.emit_signal("text_changed", value)


class ResetButton:
	extends Button
	
	
	func _init(default_value: Variant):
		set_meta("default_value", default_value)
		flat = true
		focus_mode = FOCUS_NONE
		icon = MISC.get_icon("reset")


class NameHBox:
	extends HBoxContainer
	
	
	func _init(label_text: String):
		size_flags_horizontal = SIZE_EXPAND_FILL
		var label := Label.new()
		label.size_flags_horizontal = SIZE_EXPAND_FILL
		label.text = label_text
		label.clip_text = true
		label.text_overrun_behavior = TextServer.OVERRUN_TRIM_CHAR
		add_child(label)


class SpinBoxSlider:
	extends Range
	
	enum {SUFFIX_NONE, SUFFIX_DEGREE, SUFFIX_PIXEL}
	
	@export var suffix := SUFFIX_NONE:
		set(value):
			suffix = value
			var arr := ["", "°", "px"]
			spinbox.suffix = arr[value]
	
	@export var slider_visible := true:
		set(value):
			slider_visible = value
			slider_margin.visible = value
	
	@export var editable := true:
		set(value):
			editable = value
			spinbox.editable = value
			slider.editable = value
	
	var margin := MarginContainer.new()
	var spinbox := SpinBox.new()
	var slider_margin := MarginContainer.new()
	var slider := HSlider.new()
	
	
	func _init(_suffix := SUFFIX_NONE, _slider_visible := true, _min_value := 0, _max_value := 100, _step := 1.0, _allow_greater := false, _allow_lesser := false):
		add_child(margin, false, INTERNAL_MODE_FRONT)
		margin.set_anchors_preset(PRESET_FULL_RECT)
		margin.minimum_size_changed.connect(_on_margin_minimum_size_changed)
		
		margin.add_child(spinbox)
		spinbox.select_all_on_focus = true
		spinbox.get_line_edit().context_menu_enabled = false
		spinbox.get_line_edit().gui_input.connect(_on_gui_input)
		spinbox.add_theme_icon_override("updown", ImageTexture.new())
		spinbox.get_child(0, true).focus_entered.connect(_on_spinbox_focus_toggled.bind(true))
		spinbox.get_child(0, true).focus_exited.connect(_on_spinbox_focus_toggled.bind(false))
		spinbox.alignment = HORIZONTAL_ALIGNMENT_CENTER
		
		margin.add_child(slider_margin)
		slider_margin.add_theme_constant_override("margin_left", 6)
		slider_margin.add_theme_constant_override("margin_right", 6)
		slider_margin.size_flags_vertical = SIZE_SHRINK_END
		
		slider_margin.add_child(slider)
		slider.scrollable = false
		slider.focus_mode = FOCUS_NONE
		slider.modulate.a = 0.25
		
		suffix = _suffix
		min_value = _min_value
		max_value = _max_value
		step = _step
		allow_greater = _allow_greater
		allow_lesser = _allow_lesser
		slider_visible = _slider_visible

		share(spinbox)
		spinbox.share(slider)
	
	
	func _on_margin_minimum_size_changed():
		custom_minimum_size = get_child(0, true).get_minimum_size()
	
	
	func _on_gui_input(ev: InputEvent):
		if not spinbox.get_line_edit().is_focus_edit():
			return
		if ev.is_action_pressed("ui_focus_next") or ev.is_action_pressed("ui_focus_prev"):
			value = float(spinbox.get_line_edit().text)
			get_viewport().set_input_as_handled()
			await get_tree().process_frame
			var cur_focus = get_viewport().gui_get_focus_owner()
			if cur_focus and cur_focus is LineEdit:
				cur_focus.grab_focus_edit()
			
	
	
	func _on_spinbox_focus_toggled(toggled_on: bool):
		if slider_visible:
			slider_margin.visible = not toggled_on


class Category:
	extends FoldableContainer
	
	
	func _init(_title: String):
		title = _title
		var vbox = VBoxContainer.new()
		add_child(vbox)


class InspectorLabel:
	extends Label

	var node: Node

	func _init():
		add_theme_stylebox_override("normal", get_theme_stylebox("panel", "PanelContainer"))
		name = "InspectorLabel"
		horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER


class FontOptions:
	extends OptionButton
	
	var layer: Node
	var inspector: VBoxContainer
	
	
	func _init(_layer: Node, _property: String, _inspector: VBoxContainer):
		layer = _layer
		inspector = _inspector
		item_selected.connect(_on_item_selected.bind(_property))
	
	
	func _ready():
		update_items()
	
	
	func update_items():
		clear()
		var fonts = inspector.fonts.keys()
		for i in fonts.size():
			add_item(fonts[i], i)
			if layer.font == fonts[i]:
				selected = i
	
	
	func _on_item_selected(index: int, property: String):
		layer.set(property, get_item_text(index))
