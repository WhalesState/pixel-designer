class_name NodeTree
extends ScrollContainer


var editor: Editor
var vbox := BoxContainer.new()
var tree := Tree.new()


func _init(_editor: Editor):
	editor = _editor
	name = "Layers"
	set_anchors_and_offsets_preset(PRESET_FULL_RECT)
	ignore_panel_min_size = true
	ignore_scroll_bar_min_size = true
	tree.size_flags_vertical = SIZE_EXPAND_FILL
	tree.size_flags_horizontal = SIZE_EXPAND_FILL
	vbox.name = "VBox"
	add_child(vbox)
	vbox.add_child(tree, true)
	vbox.size_flags_horizontal = SIZE_EXPAND_FILL
	vbox.size_flags_vertical = SIZE_EXPAND_FILL



func _ready():
	tree.allow_rmb_select = true
	tree.hide_root = false
	tree.item_mouse_selected.connect(_on_item_mouse_selected)
	tree.nothing_selected.connect(_on_nothing_selected)
	# item_selected.connect(_on_item_selected)
	# Viewport


func add_node_item(node_parent: TreeItem, node: Node):
	var item := tree.create_item(node_parent, 1)
	item.set_text(0, node.name)
	item.set_meta("node", node)
	# item.set_icon(0, get_theme_icon(node.get_class(), "Icons"))
	for child in node.get_children():
		add_node_item(item, child)


func _on_item_mouse_selected(_pos: Vector2, button_index: int):
	pass
	# if button_index == 2:
	# 	tree.popup_menu.popup(Rect2(get_viewport().get_mouse_position(), Vector2.ZERO))
	# prints(button_index)
	# inspector.selected = get_selected().get_meta("node")
	# var item := get_selected()
	# var node = item.get_meta("node")
	# print(node.get_class())
	# print(ClassDB.get_inheriters_from_class("Node2D"))


func _on_nothing_selected():
	tree.deselect_all()
	# inspector.selected = null


func refresh():
	tree.clear()
	var viewport := tree.create_item()
	viewport.set_text(0, "Viewport")
	# viewport.set_icon(0, get_theme_icon("SubViewport", "Icons"))
	viewport.set_meta("node", editor.image_editor.root)
	for child in editor.image_editor.root.get_children():
		add_node_item(viewport, child)
