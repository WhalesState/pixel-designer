@tool
extends VBoxContainer

var sprite_group := ButtonGroup.new()
var sprite_menu := SpriteMenu.new()


func _ready():
	add_child(sprite_menu, true, INTERNAL_MODE_FRONT)
	sprite_menu.id_pressed.connect(_on_sprite_menu_id_pressed)


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
		sprite_menu.ADD_LAYER:
			pass
		sprite_menu.REMOVE_SPRITE:
			remove_sprite(sprite_menu.button)
			sprite_menu.button = null


func remove_sprite(spr_button: SpriteButton):
	var sprite = spr_button.get_meta("node")
	sprite.get_parent().remove_child(sprite)
	sprite.queue_free()
	spr_button.get_parent().remove_child(spr_button)
	spr_button.queue_free()
	if sprite_group.get_pressed_button() == spr_button:
		if get_child_count() > 0:
			get_child(0).button_pressed = true
		else:
			get_node("%Inspector").clear()
			get_node("%Overlays").selected = null


func _on_sprite_button_selected(vp_node: SubViewport):
	get_node("%Overlays").selected = vp_node.get_parent()
	get_node("%LayerBox").sprite_vp = vp_node


class SpriteButton:
	extends Button
	
	signal selected(sprite_viewport: SubViewport)
	signal right_pressed(mpos: Vector2, sprite_button: SpriteButton)
	
	
	func _init(sprite_node: Node, sprite_group: ButtonGroup):
		text = sprite_node.name
		toggle_mode = true
		button_group = sprite_group
		clip_text = true
		alignment = HORIZONTAL_ALIGNMENT_LEFT
		set_meta("node", sprite_node)
		sprite_node.set_meta("button", self)
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
			var line_edit := LineEdit.new()
			line_edit.name = "NameEdit"
			line_edit.text = text
			line_edit.caret_blink = true
			line_edit.caret_blink_interval = 0.5
			line_edit.set_anchors_and_offsets_preset(PRESET_FULL_RECT)
			line_edit.gui_input.connect(_on_line_edit_gui_input)
			line_edit.text_submitted.connect(_on_line_edit_submitted)
			line_edit.focus_exited.connect(_on_line_edit_submitted.bind(""))
			add_child(line_edit)
			line_edit.grab_focus()
			line_edit.caret_column = text.length()
		elif ev.button_index == MOUSE_BUTTON_RIGHT:
			emit_signal("right_pressed", get_global_mouse_position(), self)
	
	
	func _on_line_edit_gui_input(ev: InputEvent):
		var line_edit: LineEdit = get_node_or_null("NameEdit")
		if not line_edit:
			return
		if not ev.is_action_pressed("ui_cancel"):
			return
		grab_focus()
	
	
	func _on_line_edit_submitted(new_text: String):
		var line_edit: LineEdit = get_node_or_null("NameEdit")
		if not line_edit:
			return
		line_edit.gui_input.disconnect(_on_line_edit_gui_input)
		line_edit.text_submitted.disconnect(_on_line_edit_submitted)
		line_edit.focus_exited.disconnect(_on_line_edit_submitted)
		line_edit.queue_free()
		grab_focus()
		if new_text.is_empty():
			return
		get_meta("node").name = new_text
		text = get_meta("node").name
		get_parent().get_node("%Inspector").get_child(0).text = text
	
	
	func _on_visibility_button_toggled(toggled_on: bool):
		get_meta("node").visible = toggled_on
	
	
	func _on_sprite_button_toggled(toggled_on: bool):
		if toggled_on:
			var inspector = get_parent().get_node("%Inspector")
			if inspector.get_child_count() > 0:
				if inspector.get_child(0).text == text:
					return
			var spr = get_meta("node")
			emit_signal("selected", spr.get_child(0))
			inspector.clear()
			inspector.add_label(spr.name)
			inspector.add_vec2_property("Transform", "Position", spr, "position", Vector2.ZERO)
			inspector.add_vec2_property("Transform", "Size", spr, "size", null, [1, 1024, 1, false, false])
			inspector.add_bool_property("Checker", "Visible", spr, "checker_visible", true)
			inspector.add_vec2_property("Checker", "Size", spr, "checker_size", null, [1, 1024, 1, false, false])
	
	
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
		get_parent().get_node("%Sprites").move_child(data.get_meta("node"), get_index())
		get_parent().move_child(data, get_index())


class Sprite:
	extends SubViewportContainer
	
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
	
	
	func get_data() -> Dictionary:
		var data := {}
		data["checker_visible"] = checker_visible
		data["checker_size"] = checker_size
		data["position"] = position
		data["size"] = size
		data["visible"] = visible
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
		return OK
	
	
	func _on_resized():
		checker.region_rect.size = (size / checker.scale).ceil()


class SpriteMenu:
	extends PopupMenu
	
	var button: SpriteButton
	
	enum {
		ADD_LAYER,
		REMOVE_SPRITE,
	}

	const ITEMS := {
		"Add Layer": ADD_LAYER,
		"Remove Sprite": REMOVE_SPRITE,
	}
	
	
	func _init():
		for item in ITEMS.keys():
			add_item(item, ITEMS[item])
