@tool
class_name ObjectInspector
extends VBoxContainer

var inspector_scroll := ScrollContainer.new()
var inspector := GridContainer.new()

var object: Object


func edit(_object: Object) -> void:
	await Main.get_singleton().process_frame
	clear()
	if object != _object:
		if object:
			object.property_list_changed.disconnect(_on_property_list_changed)
		if _object:
			_object.property_list_changed.connect(_on_property_list_changed)
	object = _object
	if not object:
		return
	for property in object.get_property_list():
		if property["usage"] & PROPERTY_USAGE_CUSTOM:
			match property["type"]:
				TYPE_INT:
					add_int_property(property["name"], object.get(property["name"]), object._property_get_tooltip(property["name"]), property["hint"], property["hint_string"])
				TYPE_FLOAT:
					add_float_property(property["name"], object.get(property["name"]), object._property_get_tooltip(property["name"]), property["hint"], property["hint_string"])
				TYPE_COLOR:
					add_color_property(property["name"], object.get(property["name"]), object._property_get_tooltip(property["name"]), property["hint"])
				TYPE_BOOL:
					print_verbose("bool")
				_:
					pass


func add_float_property(property_name: String, property_value: float, tooltip := "", hint := PROPERTY_HINT_NONE, hint_string := "") -> void:
	var button = SpinBox.new()
	button.step = 0.01
	button.size_flags_horizontal = SIZE_EXPAND_FILL
	if hint == PROPERTY_HINT_RANGE:
		var arr := hint_string.split(",")
		button.min_value = float(arr[0])
		button.max_value = float(arr[1])
		if arr.size() > 2:
			button.step = float(arr[2])
			if arr.size() > 3:
				for i in range(3, arr.size()):
					if arr[i] == "or_greater":
						button.allow_greater = true
					elif arr[i] == "or_less":
						button.allow_lesser = true
					elif arr[i].begins_with("suffix:"):
						button.suffix = arr[i].split(":")[1]
					else:
						#TODO: Match other hints.
						pass
	else:
		# PROPERTY_HINT_NONE?
		button.max_value = 10000
		button.min_value = -10000
	button.value = property_value
	button.value_changed.connect(func(value: float):
		object.set(property_name, value)
	)
	var name_control = _get_name_control(property_name, tooltip)
	if name_control.get_class() == "HBoxContainer":
		var revert_button: Button = name_control.get_child(1)
		var revert_value = object.property_get_revert(property_name)
		button.value_changed.connect(func(value: float):
			revert_button.disabled = value == revert_value
		)
		revert_button.pressed.connect(func():
			button.value = revert_value
			button.value_changed.emit(revert_value)
		)
		revert_button.disabled = property_value == revert_value
	inspector.add_child(name_control)
	inspector.add_child(button)


# 0,6,1,or_greater,or_less,hide_slider,radians_as_degrees,degrees,suffix:px
func add_int_property(property_name: String, property_value: int, tooltip := "", hint := PROPERTY_HINT_NONE, hint_string := "") -> void:
	var button
	if hint == PROPERTY_HINT_ENUM:
		button = OptionButton.new()
		var arr := hint_string.split(",")
		for i in range(arr.size()):
			button.add_item(arr[i].split(":")[0], int(arr[i].split(":")[1]))
		button.select(property_value)
		button.item_selected.connect(func(index: int):
			object.set(property_name, index)
		)
	else:
		button = SpinBox.new()
		button.size_flags_horizontal = SIZE_EXPAND_FILL
		if hint == PROPERTY_HINT_RANGE:
			var arr := hint_string.split(",")
			button.min_value = int(arr[0])
			button.max_value = int(arr[1])
			if arr.size() > 2:
				button.step = int(arr[2])
				if arr.size() > 3:
					for i in range(3, arr.size()):
						if arr[i] == "or_greater":
							button.allow_greater = true
						elif arr[i] == "or_less":
							button.allow_lesser = true
						elif arr[i].begins_with("suffix:"):
							button.suffix = arr[i].split(":")[1]
						else:
							#TODO: Match other hints.
							pass
		else:
			# PROPERTY_HINT_NONE?
			button.max_value = 10000
			button.min_value = -10000
		button.value = property_value
		button.value_changed.connect(func(value: float):
			object.set(property_name, value)
		)
	var name_control = _get_name_control(property_name, tooltip)
	if name_control.get_class() == "HBoxContainer":
		var revert_button: Button = name_control.get_child(1)
		var revert_value = object.property_get_revert(property_name)
		if button.get_class() == "SpinBox":
			button.value_changed.connect(func(value: float):
				revert_button.disabled = int(value) == revert_value
			)
			revert_button.pressed.connect(func():
				button.value = revert_value
				button.value_changed.emit(revert_value)
			)
		else:
			button.item_selected.connect(func(index: int):
				revert_button.disabled = index == revert_value
			)
			revert_button.pressed.connect(func():
				button.select(revert_value)
				button.item_selected.emit(revert_value)
			)
		revert_button.disabled = property_value == revert_value
	inspector.add_child(name_control)
	inspector.add_child(button)


func add_color_property(property_name: String, property_value: Color, tooltip := "", hint := PROPERTY_HINT_NONE) -> void:
	var name_control = _get_name_control(property_name, tooltip)
	var button := ColorButton.new()
	button.size_flags_horizontal = SIZE_EXPAND_FILL
	button.color = property_value
	button.color_changed.connect(func(color: Color):
		object.set(property_name, color)
	)
	if hint == PROPERTY_HINT_COLOR_NO_ALPHA:
		button.disable_alpha = true
	if name_control.get_class() == "HBoxContainer":
		var revert_button: Button = name_control.get_child(1)
		var revert_value = object.property_get_revert(property_name)
		button.color_changed.connect(func(color: Color):
			revert_button.disabled = color == revert_value
		)
		revert_button.pressed.connect(func():
			button.color = revert_value
			button.color_changed.emit(revert_value)
		)
		revert_button.disabled = property_value == revert_value
	inspector.add_child(name_control)
	inspector.add_child(button)


func _get_name_control(property_name: String, tooltip:= "") -> Control:
	var label := Label.new()
	label.mouse_filter = Control.MOUSE_FILTER_STOP
	label.tooltip_text = tooltip
	label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	label.set_meta("_name", property_name)
	label.set_meta("_tooltip", tooltip)
	label.text = property_name.capitalize()
	label.tooltip_text = tr(property_name.capitalize())
	label.tooltip_text += "\n%s" % tr(tooltip)
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	if object.property_can_revert(property_name):
		var revert_button = Button.new()
		revert_button.flat = true
		revert_button.icon = EditorTheme.get_singleton().icon("Reset")
		EditorTheme.get_singleton().add_to_icon_queue(revert_button, "icon", "Reset")
		var name_hbox := HBoxContainer.new()
		name_hbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		name_hbox.add_child(label)
		name_hbox.add_child(revert_button)
		return name_hbox
	return label


func clear() -> void:
	for child in inspector.get_children():
		inspector.remove_child(child)
		child.queue_free()


func _on_property_list_changed() -> void:
	edit(object)


func _init() -> void:
	name = "ObjectInspector"
	inspector_scroll.name = "InspectorScroll"
	inspector_scroll.size_flags_vertical = SIZE_EXPAND_FILL
	add_child(inspector_scroll)
	inspector.name = "InspectorGrid"
	inspector.columns = 2
	inspector.size_flags_horizontal = SIZE_EXPAND_FILL
	inspector_scroll.add_child(inspector)
