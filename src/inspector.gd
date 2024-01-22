@tool
extends VBoxContainer


func add_label(text: String, text_alignment := HORIZONTAL_ALIGNMENT_CENTER):
	var label := Label.new()
	label.horizontal_alignment = text_alignment
	label.text = text
	add_child(label)


func add_bool_property(property_name: String, property_owner: Node, property: String, default_value = null):
	var hbox := HBoxContainer.new()
	add_child(hbox)
	var name_hbox := NameHBox.new(property_name)
	hbox.add_child(name_hbox)
	var reset_button: ResetButton
	if typeof(default_value) == TYPE_BOOL:
		reset_button = ResetButton.new(default_value)
		name_hbox.add_child(reset_button)
	var checkbox := CheckBox.new()
	checkbox.flat = true
	checkbox.text = "On"
	checkbox.size_flags_horizontal = SIZE_EXPAND_FILL
	checkbox.button_pressed = property_owner.get(property)
	hbox.add_child(checkbox)
	if reset_button:
		reset_button.visible = default_value != checkbox.button_pressed
		reset_button.pressed.connect(_on_reset_property_pressed.bind([checkbox], default_value))
	checkbox.toggled.connect(_on_bool_checkbox_toggled.bind(property_owner, property, reset_button))


func add_vec2_property(property_name: String, property_owner: Node, property: String, default_value = null, hint := [-9999,9999,1.0, true, true]):
	var hbox := HBoxContainer.new()
	add_child(hbox)
	var name_hbox := NameHBox.new(property_name)
	hbox.add_child(name_hbox)
	var reset_button: ResetButton
	if typeof(default_value) == TYPE_VECTOR2:
		reset_button = ResetButton.new(default_value)
		name_hbox.add_child(reset_button)
	var vbox := VBoxContainer.new()
	vbox.size_flags_horizontal = SIZE_EXPAND_FILL
	hbox.add_child(vbox)
	var x_spinbox := SpinBoxSlider.new(SpinBoxSlider.SUFFIX_PIXEL, false, hint[0], hint[1], hint[2], hint[3], hint[4])
	x_spinbox.value = property_owner.get(property).x
	vbox.add_child(x_spinbox)
	var y_spinbox := SpinBoxSlider.new(SpinBoxSlider.SUFFIX_PIXEL, false, hint[0], hint[1], hint[2], hint[3], hint[4])
	y_spinbox.value = property_owner.get(property).y
	vbox.add_child(y_spinbox)
	if reset_button:
		reset_button.visible = default_value != Vector2(x_spinbox.value, y_spinbox.value)
		reset_button.pressed.connect(_on_reset_property_pressed.bind([x_spinbox, y_spinbox], default_value))
	x_spinbox.value_changed.connect(_on_vec2_spinbox_value_changed.bind(x_spinbox, y_spinbox, property_owner, property, reset_button))
	y_spinbox.value_changed.connect(_on_vec2_spinbox_value_changed.bind(x_spinbox, y_spinbox, property_owner, property, reset_button))


func clear():
	for child in get_children():
		remove_child(child)
		child.queue_free()


func _on_bool_checkbox_toggled(toggled_on: bool, property_owner: Node, property: String, reset_button: Button):
	property_owner.set(property, toggled_on)
	if reset_button:
		reset_button.visible = reset_button.get_meta("default_value") != toggled_on


func _on_vec2_spinbox_value_changed(_value: float, x_value_owner: Range, y_value_owner: Range, property_owner: Node, property: String, reset_button = null):
	var value = Vector2(x_value_owner.value, y_value_owner.value)
	property_owner.set(property, value)
	if reset_button:
		reset_button.visible = reset_button.get_meta("default_value") != value
	get_node("%Overlays").queue_redraw()


func _on_reset_property_pressed(nodes: Array, value: Variant):
	match typeof(value):
		TYPE_BOOL:
			nodes[0].button_pressed = value
		TYPE_VECTOR2:
			nodes[0].value = value.x
			nodes[1].value = value.y
			get_node("%Overlays").queue_redraw()


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
	
	
	func _init(_suffix := SUFFIX_NONE, _slider_visible := true, _min_value := 0, _max_value := 100, _step := 1, _allow_greater := false, _allow_lesser := false):
		add_child(margin, false, INTERNAL_MODE_FRONT)
		margin.set_anchors_preset(PRESET_FULL_RECT)
		margin.minimum_size_changed.connect(_on_margin_minimum_size_changed)
		
		margin.add_child(spinbox)
		spinbox.select_all_on_focus = true
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
		
		share(spinbox)
		spinbox.share(slider)
		slider.modulate.a = 0.25
		
		suffix = _suffix
		min_value = _min_value
		max_value = _max_value
		step = _step
		allow_greater = _allow_greater
		allow_lesser = _allow_lesser
		slider_visible = _slider_visible
	
	
	func _on_margin_minimum_size_changed():
		custom_minimum_size = get_child(0, true).get_minimum_size()
	
	
	func _on_spinbox_focus_toggled(toggled_on: bool):
		if slider_visible:
			slider_margin.visible = not toggled_on
