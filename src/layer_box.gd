@tool
extends Tree

var layer_menu := LayerMenu.new()
var root_menu := PopupMenu.new()
var sprite_vp: SubViewport:
	set(value):
		if not value is SubViewport:
			sprite_vp = null
			clear()
			return
		sprite_vp = value
		reload_layers_tree()


func _init() -> void:
	allow_rmb_select = true
	item_activated.connect(_on_item_activated)
	item_edited.connect(_on_item_edited)
	item_mouse_selected.connect(_on_item_mouse_selected)
	item_selected.connect(_on_item_selected)
	add_child(layer_menu)
	layer_menu.id_pressed.connect(_on_layer_menu_id_pressed)
	add_child(root_menu)
	root_menu.add_item("Add child layer", LayerMenu.ADD_CHILD_LAYER)
	root_menu.id_pressed.connect(_on_layer_menu_id_pressed)


func _on_layer_menu_id_pressed(id: int) -> void:
	match id:
		LayerMenu.ADD_CHILD_LAYER:
			# TODO: show add layer window
			var label_layer = LabelLayer.new()
			get_selected().get_meta("node").add_child(label_layer)
			reload_layers_tree()
		LayerMenu.DUPLICATE_LAYER:
			pass
		LayerMenu.CONVERT_TO_TEXTURE_LAYER:
			pass
		LayerMenu.RENAME_LAYER:
			pass
		LayerMenu.REMOVE_LAYER:
			pass


func _on_item_activated():
	if get_selected().get_meta("node") == sprite_vp:
		print("root")
		return
	# TODO: convert to editable item to rename or show LineEdit.
	print("Activated")


func _on_item_edited():
	# TODO: rename layer and convert to item.
	print("Edited")


func _on_item_mouse_selected(_mpos: Vector2, mouse_button_index: int):
	if not has_focus():
		grab_focus()
	if not mouse_button_index == MOUSE_BUTTON_RIGHT:
		return
	var selected_node = get_selected().get_meta("node")
	if selected_node == sprite_vp:
		root_menu.popup(Rect2(DisplayServer.mouse_get_position(), Vector2.ZERO))
	else:
		layer_menu.popup(Rect2(DisplayServer.mouse_get_position(), Vector2.ZERO))


func _on_item_selected():
	if get_selected().get_meta("node") == sprite_vp:
		print("root")
		return
	# TODO: Update inspector with selected layer.
	get_node("%Inspector").load_properties(get_selected().get_meta("node"))
	# print("Selected")


func reload_layers_tree() -> void:
	clear()
	if not sprite_vp:
		return
	var root := create_item()
	root.set_meta("node", sprite_vp)
	root.set_text(0, sprite_vp.name)
	for child in sprite_vp.get_children():
		add_layer_item(root, child)


func add_layer_item(node_parent: TreeItem, node: Node):
	var item := create_item(node_parent, 1)
	item.set_text(0, node.name)
	item.set_meta("node", node)
	for child in node.get_children():
		add_layer_item(item, child)


class LabelLayer:
	extends Label
	
	var actual_position := Vector2.ZERO:
		set(value):
			actual_position = value
			position = actual_position - pivot_offset
	
	
	func _init():
		name = "LabelLayer"
		text = "TEST"
	
	
	## property: [CATEGORY, DISPLAY_NAME, TYPE, DEFAULT_VALUE, HINTS]
	func get_properties() -> Dictionary:
		var properties = {}
		properties["actual_position"] = ["Transform", "Position", TYPE_VECTOR2, Vector2.ZERO]
		return properties


class LayerMenu:
	extends PopupMenu
	
	enum {
		ADD_CHILD_LAYER,
		DUPLICATE_LAYER,
		CONVERT_TO_TEXTURE_LAYER,
		RENAME_LAYER,
		REMOVE_LAYER,
	}
	
	const ITEMS := {
		"Add child layer": ADD_CHILD_LAYER,
		"Duplicate layer": DUPLICATE_LAYER,
		"Convert to texture layer": CONVERT_TO_TEXTURE_LAYER,
		"Rename layer": RENAME_LAYER,
		"Remove layer": REMOVE_LAYER,
	}
	
	
	func _init():
		for item in ITEMS.keys():
			add_item(item, ITEMS[item])
