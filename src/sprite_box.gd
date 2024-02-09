@tool
extends VBoxContainer

var sprite_group := ButtonGroup.new()
var sprite_menu := SpriteMenu.new()


func _ready():
	add_child(sprite_menu, true, INTERNAL_MODE_FRONT)
	sprite_menu.id_pressed.connect(_on_sprite_menu_id_pressed)


func clear():
	get_node("%Camera").reset()
	get_node("%Inspector").clear()
	get_node("%Inspector").fonts = {}
	get_node("%LayerBox").sprite_vp = null
	get_node("%Overlays").selected = null
	for child in get_children():
		child.sprite.get_parent().remove_child(child.sprite)
		child.sprite.queue_free()
		remove_child(child)
		child.queue_free()


func create_new_sprite(spr_name := "Sprite", spr_size := Vector2(16, 16)) -> Sprite:
	var sprite := Sprite.new(spr_size)
	get_node("%Sprites").add_child(sprite)
	sprite.name = spr_name
	return sprite


func create_sprite_button(sprite: Sprite):
	var spr_button := SpriteButton.new(sprite, sprite_group)
	spr_button.selected.connect(_on_sprite_button_selected)
	spr_button.right_pressed.connect(_on_sprite_button_right_pressed)
	add_child(spr_button)
	spr_button.button_pressed = true


func _on_create_sprite_pressed():
	var sprite = create_new_sprite()
	create_sprite_button(sprite)


func _on_sprite_button_right_pressed(mpos: Vector2, spr_button: SpriteButton):
	sprite_menu.button = spr_button
	spr_button.grab_focus()
	sprite_menu.popup(Rect2i(mpos, Vector2i.ZERO))


func _on_sprite_menu_id_pressed(id: int):
	match id:
		SpriteMenu.RENAME_SPRITE:
			pass
		SpriteMenu.REMOVE_SPRITE:
			remove_sprite(sprite_menu.button)
			sprite_menu.button = null


func remove_sprite(spr_button: SpriteButton):
	var sprite = spr_button.sprite
	sprite.get_parent().remove_child(sprite)
	sprite.queue_free()
	spr_button.get_parent().remove_child(spr_button)
	spr_button.queue_free()
	if sprite_group.get_pressed_button() == spr_button:
		if get_child_count() > 0:
			get_child(0).button_pressed = true
		else:
			get_node("%Inspector").clear()


func _on_sprite_button_selected(spr_node: Sprite):
	get_node("%Overlays").selected = spr_node
	get_node("%LayerBox").sprite_vp = spr_node.get_child(0)
	get_node("%Inspector").load_properties(spr_node)


class SpriteButton:
	extends Button
	
	signal selected(sprite_node: Sprite)
	signal right_pressed(mpos: Vector2, sprite_button: SpriteButton)
	
	var sprite: Sprite

	
	func _init(sprite_node: Node, sprite_group: ButtonGroup):
		text = sprite_node.name
		toggle_mode = true
		button_group = sprite_group
		clip_text = true
		alignment = HORIZONTAL_ALIGNMENT_LEFT
		sprite = sprite_node
		sprite_node.sprite_button = self
		var visibility_button := TextureButton.new()
		visibility_button.focus_mode = FOCUS_NONE
		visibility_button.texture_normal = MISC.get_icon("hidden")
		visibility_button.texture_pressed = MISC.get_icon("visible")
		visibility_button.toggle_mode = true
		visibility_button.button_pressed = sprite_node.visible
		visibility_button.set_anchors_and_offsets_preset(PRESET_CENTER_RIGHT)
		visibility_button.toggled.connect(_on_visibility_button_toggled)
		add_child(visibility_button)
		toggled.connect(_on_sprite_button_toggled)
	
	
	func _gui_input(ev: InputEvent):
		if not (ev is InputEventMouseButton and ev.pressed):
			return
		if ev.button_index == MOUSE_BUTTON_LEFT and ev.double_click:
			var line_edit := NodeRenamer.new(sprite)
			line_edit.set_anchors_and_offsets_preset(PRESET_FULL_RECT)
			line_edit.node_renamed.connect(_on_sprite_renamed)
			add_child(line_edit)
		elif ev.button_index == MOUSE_BUTTON_RIGHT:
			emit_signal("right_pressed", DisplayServer.mouse_get_position(), self)
	
	
	func _on_sprite_renamed(new_name: String):
		text = new_name
		get_node("%Inspector").label.text = text
	
	
	func _on_visibility_button_toggled(toggled_on: bool):
		sprite.visible = toggled_on
	
	
	func _on_sprite_button_toggled(toggled_on: bool):
		if toggled_on:
			if get_parent().get_node("%Inspector").selected:
				if get_parent().get_node("%Inspector").selected == sprite:
					return
			emit_signal("selected", sprite)
	
	
	func _get_drag_data(_pos: Vector2):
		var button := Button.new()
		button.text = text
		set_drag_preview(button)
		return self
	
	
	func _can_drop_data(_pos: Vector2, data: Variant):
		if data != self and data is SpriteButton:
			return true
		return false
	
	
	func _drop_data(_pos: Vector2, data: Variant):
		get_parent().get_node("%Sprites").move_child(data.sprite, get_index())
		get_parent().move_child(data, get_index())


class Sprite:
	extends SubViewportContainer
	
	var sprite_button: SpriteButton
	var checker := Sprite2D.new()
	var checker_visible := true:
		set(value):
			checker_visible = value
			checker.visible = checker_visible
	
	var checker_size := Vector2.ONE:
		set(value):
			checker_size = value
			checker.scale = value
			checker.region_rect.size = (size / checker.scale).ceil()
	
	
	func _init(spr_size := Vector2(16, 16)):
		size = spr_size
		stretch = true
		var vp := SubViewport.new()
		vp.name = "Viewport"
		vp.canvas_item_default_texture_filter = Viewport.DEFAULT_CANVAS_ITEM_TEXTURE_FILTER_NEAREST
		vp.transparent_bg = true
		add_child(vp, true)
		material = MISC.SPRITE_MATERIAL
		# Checker
		checker.centered = false
		checker.texture_repeat = CanvasItem.TEXTURE_REPEAT_ENABLED
		checker.region_enabled = true
		checker.region_rect.size = size
		checker_size = Vector2(4, 4)
		checker.texture = MISC.get_icon("checker")
		vp.add_child(checker, false, INTERNAL_MODE_FRONT)
		resized.connect(_on_resized)
	
	
	func _set(property: StringName, _value: Variant):
		if property in ["position", "size"]:
			get_parent().get_node("%Overlays").queue_redraw()
		return false
	
	
	func get_data() -> Dictionary:
		var data := {}
		data["checker_visible"] = checker_visible
		data["checker_size"] = checker_size
		data["position"] = position
		data["size"] = size
		data["visible"] = visible
		var layers := {}
		for layer in get_child(0).get_children():
			layers[layer.name] = layer.get_data()
		data["layers"] = layers
		return data
	
	
	func load_data(data: Dictionary) -> int:
		# set them manually one by one for now, just in case it sets another class variable later.
		if data.is_empty():
			return ERR_INVALID_DATA
		checker_visible = data["checker_visible"]
		checker_size = data["checker_size"]
		position = data["position"]
		size = data["size"]
		visible = data["visible"]
		for layer_name in data["layers"].keys():
			match data["layers"][layer_name]["type"]:
				"LabelLayer":
					var label_layer = LabelLayer.new(get_parent().get_node("%Inspector"))
					label_layer.name = layer_name
					get_child(0).add_child(label_layer)
					label_layer.load_data(data["layers"][layer_name])
		return OK
	

	func get_properties() -> Dictionary:
		var properties := {}
		properties["position"] = ["Transform", "Position", TYPE_VECTOR2, Vector2.ZERO, []]
		properties["size"] = ["Transform", "Size", TYPE_VECTOR2, null, [1, 1024, 1, false, false]]
		properties["checker_visible"] = ["Checker", "Visible", TYPE_BOOL, true, []]
		properties["checker_size"] = ["Checker", "Size", TYPE_VECTOR2, null, [1, 1024, 1, false, false]]
		return properties
	

	func _on_resized():
		checker.region_rect.size = (size / checker.scale).ceil()


class SpriteMenu:
	extends PopupMenu

	enum {
		RENAME_SPRITE,
		REMOVE_SPRITE,
	}

	const ITEMS := {
		"Rename sprite": RENAME_SPRITE,
		"Remove sprite": REMOVE_SPRITE,
	}

	var button: SpriteButton


	func _init():
		for item in ITEMS.keys():
			add_item(item, ITEMS[item])
