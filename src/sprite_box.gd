@tool
extends VBoxContainer

var sprite_group := ButtonGroup.new()
var sprite_menu := SpriteMenu.new()


func _ready():
	add_child(sprite_menu, true, INTERNAL_MODE_FRONT)
	sprite_menu.id_pressed.connect(_on_sprite_menu_id_pressed)


func _on_add_sprite_pressed():
	create_sprite("Hello", Vector2(24, 24))


func create_sprite(spr_name := "Sprite", spr_size := Vector2(16, 16)):
	var sprite := Sprite.new(spr_size)
	get_node("%Sprites").add_child(sprite)
	sprite.name = spr_name
	var layer = Layer.new()
	sprite.get_child(0).add_child(layer)
	layer.name = "Layer"
	var spr_button := SpriteButton.new(sprite, sprite_group)
	spr_button.selected.connect(_on_sprite_button_selected)
	spr_button.right_pressed.connect(_on_sprite_button_right_pressed)
	add_child(spr_button)
	spr_button.button_pressed = true


func _on_sprite_button_right_pressed(mpos: Vector2, spr_button: SpriteButton):
	sprite_menu.button = spr_button
	spr_button.grab_focus()
	sprite_menu.popup(Rect2i(mpos, Vector2i.ZERO))


func _on_sprite_menu_id_pressed(id: int):
	match id:
		sprite_menu.REMOVE_SPRITE:
			remove_sprite(sprite_menu.button)


func remove_sprite(spr_button: SpriteButton):
	var sprite = spr_button.get_meta("node")
	sprite.get_parent().remove_child(sprite)
	sprite.queue_free()
	spr_button.get_parent().remove_child(spr_button)
	spr_button.queue_free()
	if sprite_group.get_pressed_button() == spr_button:
		if get_child_count() > 0:
			get_child(0).button_pressed = true


func create_sprite_layer(spr_node: SubViewportContainer, layer_name := "Layer"):
	var layer = Layer.new()
	spr_node.get_child(0).add_child(layer)
	layer.name = layer_name
	# Test
	layer.texture = preload("res://test.png")


func _on_sprite_button_selected(vp_node: SubViewport):
	var layers_tab: TabBox = get_node("%LayersTab")
	layers_tab.clear()
	# var cur_button := sprite_group.get_pressed_button()
	for child in vp_node.get_children():
		var layer_ind := layers_tab.add_tab(child.name, true, true, false, true)
		layers_tab.tab_bar.get_child(layer_ind).set_meta("node", child)


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
		var visibility_button := TextureButton.new()
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
			line_edit.text = text
			line_edit.caret_blink = true
			line_edit.caret_blink_interval = 0.5
			line_edit.set_anchors_and_offsets_preset(PRESET_FULL_RECT)
			line_edit.text_submitted.connect(_on_line_edit_submitted.bind(line_edit))
			line_edit.focus_exited.connect(_on_line_edit_submitted.bind("", line_edit, false))
			add_child(line_edit)
			line_edit.grab_focus()
			line_edit.caret_column = text.length()
		elif ev.button_index == MOUSE_BUTTON_RIGHT:
			emit_signal("right_pressed", get_global_mouse_position(), self)
	
	
	func _on_line_edit_submitted(new_text: String, line_edit: LineEdit, rename := true):
		remove_child(line_edit)
		line_edit.queue_free()
		grab_focus()
		if rename:
			get_meta("node").name = new_text
			text = get_meta("node").name
	
	
	func _on_visibility_button_toggled(toggled_on: bool):
		get_meta("node").visible = toggled_on
	
	
	func _on_sprite_button_toggled(toggled_on: bool):
		if toggled_on:
			emit_signal("selected", get_meta("node").get_child(0))
	
	
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
		get_parent().viewport.move_child(data.get_meta("node"), get_index())
		get_parent().move_child(data, get_index())


class Layer:
	extends Sprite2D
	
	var cells := []
	var cur_cell = 0
	
	func _init():
		centered = false


class Sprite:
	extends SubViewportContainer
	
	
	func _init(spr_size := Vector2(16, 16)):
		size = spr_size
		stretch = true
		var vp := SubViewport.new()
		vp.canvas_item_default_texture_filter = Viewport.DEFAULT_CANVAS_ITEM_TEXTURE_FILTER_NEAREST
		vp.transparent_bg = true
		add_child(vp, true)
		material = CanvasItemMaterial.new()
		material.blend_mode = CanvasItemMaterial.BLEND_MODE_PREMULT_ALPHA
		# Checker
		var checker := Sprite2D.new()
		checker.centered = false
		checker.texture_repeat = CanvasItem.TEXTURE_REPEAT_ENABLED
		checker.region_enabled = true
		checker.region_rect.size = spr_size
		checker.name = "Checker"
		checker.texture = MISC.get_icon("checker")
		vp.add_child(checker, true, INTERNAL_MODE_FRONT)
		set_meta("checker", checker)
	
	
	
	func _draw():
		draw_rect(Rect2(Vector2.ZERO, size), Color(1.0, 1.0, 1.0, 0.5), false)


class SpriteMenu:
	extends PopupMenu
	
	var button: SpriteButton
	
	enum {
		REMOVE_SPRITE,
	}

	const ITEMS := {
		"Remove Sprite": REMOVE_SPRITE,
	}
	
	
	func _init():
		for item in ITEMS.keys():
			add_item(item, ITEMS[item])
