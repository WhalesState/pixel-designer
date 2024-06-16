"""*********************************************************************
*                        This file is Part of                          *
*                           Pixel Designer                             *
************************************************************************
* Copyright (c) 2023-present (Erlend Sogge Heggen), (Mounir Tohami).   *
* License : PolyForm Strict License 1.0.0                              *
* https://polyformproject.org/licenses/strict/1.0.0                    *
* Made with : Pixel Engine (Godot Engine hard fork)                    *
* https://github.com/WhalesState/godot-pixel-engine                    *
*********************************************************************"""

class_name NodeEditor
extends ControlViewport

enum {
	ACTION_NONE,
	ACTION_MOVE,
	ACTION_RESIZE,
	ACTION_ROTATE
}

enum {
	DRAG_NONE,
	DRAG_SELECTION,
	DRAG_LEFT,
	DRAG_TOP_LEFT,
	DRAG_TOP,
	DRAG_TOP_RIGHT,
	DRAG_RIGHT,
	DRAG_BOTTOM_RIGHT,
	DRAG_BOTTOM,
	DRAG_BOTTOM_LEFT,
}

var select_handle := preload("res://icons/select_handle.png")

var selected: Control = null:
	set(value):
		selected = value as Control
		get_control_viewport().queue_redraw()

var cur_action := ACTION_NONE
var drag_type := DRAG_NONE
var is_dragging := false
var prev_rect := Rect2()
var prev_mpos := Vector2.ZERO
var drag_to := Vector2.ZERO
var old_position := Vector2.ZERO

var editor: Editor
var root_container := SubViewportContainer.new()
var root := SubViewport.new()
var viewport := SubViewport.new()
var undo_redo: UndoRedo


func _init(_editor: Editor):
	editor = _editor
	undo_redo = editor.undo_redo
	name = "NodeEditor"
	var svp := SubViewportContainer.new()
	svp.set_anchors_and_offsets_preset(PRESET_FULL_RECT)
	svp.stretch = true
	add_child(svp)
	svp.add_child(viewport)
	view_transform_changed.connect(func(transform: Transform2D):
		viewport.set_canvas_transform(transform)
	)
	root_container.stretch = true
	viewport.add_child(root_container)
	root_container.add_child(root)
	var spr = TextureRect.new()
	spr.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	spr.size = Vector2(64, 64)
	spr.texture_filter = Control.TEXTURE_FILTER_LINEAR
	root.canvas_item_default_texture_filter = Viewport.DEFAULT_CANVAS_ITEM_TEXTURE_FILTER_LINEAR
	spr.texture = load("./icon.svg")
	root.add_child(spr)
	# Load editor settings. Maybe this can be project based.
	var editor_settings = editor.editor_settings
	show_grid = editor_settings.get_value("editor", "show_grid", true)
	show_rulers = editor_settings.get_value("editor", "show_rulers", true)
	show_guides = editor_settings.get_value("editor", "show_guides", true)
	grid_offset = editor_settings.get_value("editor", "grid_offset", Vector2.ZERO)
	grid_step = editor_settings.get_value("editor", "grid_step", Vector2(16, 16))
	primary_grid_step = editor_settings.get_value("editor", "primary_grid_step", Vector2i(8, 8))
	# Load project settings.
	var project_settings = editor.project_settings
	vguides = project_settings.get_value("project", "vguides", PackedInt32Array())
	hguides = project_settings.get_value("project", "hguides", PackedInt32Array())
	view_size.x = project_settings.get_value("project", "view_width", 16)
	view_size.y = project_settings.get_value("project", "view_height", 16)
	root_container.size = view_size
	root.snap_2d_transforms_to_pixel = project_settings.get_value("project", "snap_2d_transforms_to_pixel", false)
	root.snap_2d_vertices_to_pixel = project_settings.get_value("project", "snap_2d_vertices_to_pixel", false)
	guides_changed.connect(func():
		project_settings.set_value("project", "hguides", hguides)
		project_settings.set_value("project", "vguides", vguides)
		editor.save_project_settings()
	)
	# Options Menu.
	var options_menu := MenuButton.new()
	options_menu.icon = preload("res://icons/options.svg")
	var popup := options_menu.get_popup()
	popup.add_check_item("Show Grid", 0)
	popup.set_item_checked(0, show_grid)
	var grid_settings_window = GridSettingsWindow.new(self)
	add_child(grid_settings_window)
	popup.add_item("Grid Settings", 1)
	popup.add_check_item("Show Rulers", 2)
	popup.set_item_checked(2, show_rulers)
	popup.add_check_item("Show Guides", 3)
	popup.set_item_checked(3, show_guides)
	popup.add_item("Clear Guides", 4)
	popup.id_pressed.connect(func(id: int):
		if id == 0:
			popup.set_item_checked(0, not show_grid)
			show_grid = popup.is_item_checked(0)
			editor_settings.set_value("editor", "show_grid", show_grid)
			editor.save_editor_settings()
		elif id == 1:
			grid_settings_window.popup_centered()
		elif id == 2:
			popup.set_item_checked(2, not show_rulers)
			show_rulers = popup.is_item_checked(2)
			editor_settings.set_value("editor", "show_rulers", show_rulers)
			editor.save_editor_settings()
		elif id == 3:
			popup.set_item_checked(3, not show_guides)
			show_guides = popup.is_item_checked(3)
			editor_settings.set_value("editor", "show_guides", show_guides)
			editor.save_editor_settings()
		elif id == 4:
			clear_guides()
	)
	get_controls_container().add_child(options_menu, false, INTERNAL_MODE_BACK)


func _input(ev: InputEvent):
	var k: InputEventKey = ev as InputEventKey
	if not k or not k.pressed:
		return
	if selected:
		if k.keycode == KEY_LEFT or k.keycode == KEY_RIGHT or k.keycode == KEY_UP or k.keycode == KEY_DOWN:
			var dir := Vector2(
				int(k.keycode == KEY_RIGHT) - int(k.keycode == KEY_LEFT),
				int(k.keycode == KEY_DOWN) - int(k.keycode == KEY_UP) 
			)
			var to = dir
			if k.is_command_or_control_pressed():
				if k.shift_pressed:
					to *= (grid_step * Vector2(primary_grid_step))
				else:
					to *= grid_step
			var new_pos = selected.position + to
			if k.ctrl_pressed:
				new_pos = new_pos.round()
			action_move_node(selected, selected.position, new_pos)
			get_viewport().set_input_as_handled()
	if k.echo:
		return
	if k.keycode == KEY_F:
		center_view()
		get_viewport().set_input_as_handled()
	if k.keycode == KEY_E and k.ctrl_pressed:
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png("test.png")
		get_viewport().set_input_as_handled()
		print("Export")


func _gui_input(ev: InputEvent):
	var mb: InputEventMouseButton = ev as InputEventMouseButton
	if mb and mb.button_index == MOUSE_BUTTON_LEFT:
		if mb.pressed:
			cur_action = ACTION_NONE
			drag_type = DRAG_NONE
			prev_mpos = Vector2.ZERO
			if selected:
				const dragger = [
					DRAG_TOP_LEFT,
					DRAG_TOP,
					DRAG_TOP_RIGHT,
					DRAG_RIGHT,
					DRAG_BOTTOM_RIGHT,
					DRAG_BOTTOM,
					DRAG_BOTTOM_LEFT,
					DRAG_LEFT
				]
				var resize_drag = DRAG_NONE
				var radius = (select_handle.get_size().x / 2) * 1.5
				var transform := get_custom_transform() * selected.get_transform()
				var rect = Rect2(Vector2.ZERO, selected.size)
				var arr = [
					transform._xform(rect.position),
					transform._xform(rect.position + Vector2(rect.size.x, 0)),
					transform._xform(rect.position + rect.size),
					transform._xform(rect.position + Vector2(0, rect.size.y))
				]
				for i in range(4):
					var prev: int = (i + 3) % 4
					var next: int = (i + 1) % 4
					var ofs: Vector2 = ((arr[i] - arr[prev]).normalized() + ((arr[i] - arr[next]).normalized())).normalized()
					ofs *= (select_handle.get_size().x / 2)
					ofs += arr[i];
					if ofs.distance_to(mb.position) < radius:
						resize_drag = dragger[i * 2]
					ofs = (arr[i] + arr[next]) / 2
					ofs += (arr[next] - arr[i]).orthogonal().normalized() * (select_handle.get_size().x / 2);
					if (ofs.distance_to(mb.position) < radius):
						resize_drag = dragger[i * 2 + 1];
				if resize_drag != DRAG_NONE:
					drag_type = resize_drag
					cur_action = ACTION_RESIZE
					prev_mpos = mb.position
			if drag_type == DRAG_NONE:
				for j in range(root.get_child_count() - 1, -1, -1):
					var node: Control = root.get_child(j) as Control
					if not node:
						return
					var rect = Rect2(Vector2.ZERO, node.size)
					var xform = get_custom_transform() * node.get_transform()
					if rect.has_point(xform.affine_inverse()._xform(mb.position)) or (mb.alt_pressed and selected):
						if selected == node:
							if mb.shift_pressed:
								continue
							cur_action = ACTION_MOVE
							prev_mpos = mb.position
							return
						if not mb.alt_pressed or not selected:
							action_select_node(node)
						cur_action = ACTION_MOVE
						prev_mpos = mb.position
						return
				action_select_node(null)
		else:
			if is_dragging:
				if cur_action == ACTION_MOVE:
					action_move_node(selected, old_position, selected.position, false)
					old_position = Vector2.ZERO
				elif cur_action == ACTION_RESIZE:
					action_resize_node(selected, prev_rect, selected.get_rect(), false)
					prev_rect = Rect2()
				is_dragging = false
			drag_type = DRAG_NONE
			cur_action = ACTION_NONE
	var mm: InputEventMouseMotion = ev as InputEventMouseMotion
	if mm and mm.button_mask == MOUSE_BUTTON_MASK_LEFT:
		if cur_action == ACTION_MOVE:
			if not is_dragging and prev_mpos.distance_to(mm.position) > 8:
				old_position = selected.position
				is_dragging = true
			if not is_dragging:
				return
			var drag_from := get_custom_transform().affine_inverse()._xform(prev_mpos)
			drag_to = get_custom_transform().affine_inverse()._xform(mm.position)
			var new_pos = round(old_position + (drag_to - drag_from))
			if mm.shift_pressed:
				if abs(new_pos.x - old_position.x) > abs(new_pos.y - old_position.y):
					new_pos.y = old_position.y
				else:
					new_pos.x = old_position.x
			selected.position = new_pos
			get_control_viewport().queue_redraw()
			get_viewport().set_input_as_handled()
		elif cur_action == ACTION_RESIZE:
			if not is_dragging:
				prev_rect = selected.get_rect()
				is_dragging = true
			var current_begin := prev_rect.position
			var current_end := prev_rect.size
			var max_begin := current_begin + ((current_end - selected.get_minimum_size()) / 2.0) if mm.alt_pressed else current_begin + current_end - selected.get_minimum_size()
			var min_end := (current_end + selected.get_minimum_size()) / 2.0 if mm.alt_pressed else selected.get_minimum_size()
			var drag_from := get_custom_transform().affine_inverse()._xform(prev_mpos)
			drag_to = get_custom_transform().affine_inverse()._xform(mm.position)
			var drag_begin := current_begin + (drag_to - drag_from)
			var drag_end := current_end + (drag_to - drag_from)
			# Horizontal resize.
			if drag_type == DRAG_LEFT or drag_type == DRAG_TOP_LEFT or drag_type == DRAG_BOTTOM_LEFT:
				current_begin.x = min(drag_begin.x, max_begin.x)
				current_end.x += prev_rect.position.x - current_begin.x
			elif drag_type == DRAG_RIGHT or drag_type == DRAG_TOP_RIGHT or drag_type == DRAG_BOTTOM_RIGHT:
				current_end.x = max(drag_end.x, min_end.x)
			# Vertical resize.
			if drag_type == DRAG_TOP or drag_type == DRAG_TOP_LEFT or drag_type == DRAG_TOP_RIGHT:
				current_begin.y = min(drag_begin.y, max_begin.y)
				current_end.y += prev_rect.position.y - current_begin.y
			elif drag_type == DRAG_BOTTOM or drag_type == DRAG_BOTTOM_LEFT or drag_type == DRAG_BOTTOM_RIGHT:
				current_end.y = max(drag_end.y, min_end.y)
			# Uniform resize.
			if mm.shift_pressed:
				var aspect: float = prev_rect.size.y / prev_rect.size.x
				if drag_type == DRAG_LEFT or drag_type == DRAG_RIGHT:
					current_end.y = current_end.x * aspect
				elif drag_type == DRAG_TOP or drag_type == DRAG_BOTTOM:
					current_end.x = current_end.y / aspect
				else:
					var new_aspect: float = current_end.y / current_end.x
					if new_aspect > aspect:
						if drag_type == DRAG_BOTTOM_LEFT or drag_type == DRAG_TOP_LEFT:
							current_begin.x = prev_rect.position.x + ((prev_rect.size.y - current_end.y) / aspect)
						current_end.x = current_end.y / aspect
					elif new_aspect < aspect:
						if drag_type == DRAG_TOP_RIGHT or drag_type == DRAG_TOP_LEFT:
							current_begin.y = prev_rect.position.y + ((prev_rect.size.x - current_end.x) * aspect) 
						current_end.y = current_end.x * aspect
			# Symmetric resize.
			if mm.alt_pressed:
				if drag_type == DRAG_LEFT or drag_type == DRAG_TOP_LEFT or drag_type == DRAG_BOTTOM_LEFT:
					current_end.x += prev_rect.position.x - current_begin.x
				elif drag_type == DRAG_RIGHT or drag_type == DRAG_TOP_RIGHT or drag_type == DRAG_BOTTOM_RIGHT:
					current_begin.x += prev_rect.size.x - current_end.x
					current_end.x += prev_rect.position.x - current_begin.x
				if drag_type == DRAG_TOP or drag_type == DRAG_TOP_LEFT or drag_type == DRAG_TOP_RIGHT:
					current_end.y += prev_rect.position.y - current_begin.y
				elif drag_type == DRAG_BOTTOM or drag_type == DRAG_BOTTOM_LEFT or drag_type == DRAG_BOTTOM_RIGHT:
					current_begin.y += prev_rect.size.y - current_end.y
					current_end.y += prev_rect.position.y - current_begin.y
			# Snap to pixels.
			if current_begin.x != prev_rect.position.x:
				current_end.x -= round(current_begin.x) - current_begin.x
				current_begin.x = round(current_begin.x)
			if current_begin.y != prev_rect.position.y:
				current_end.y -= round(current_begin.y) - current_begin.y
				current_begin.y = round(current_begin.y)
			if current_begin.x + current_end.x != prev_rect.position.x + prev_rect.size.x:
				current_end.x = round(current_end.x)
			if current_begin.y + current_end.y != prev_rect.position.y + prev_rect.size.y:
				current_end.y = round(current_end.y)
			selected.position = current_begin
			selected.size = current_end
			get_control_viewport().queue_redraw()
			get_viewport().set_input_as_handled()


func _custom_draw(control: Control):
	if selected:
		var transform := get_custom_transform() * selected.get_transform()
		var rect = Rect2(Vector2.ZERO, selected.size)
		var arr = [
			transform._xform(rect.position),
			transform._xform(rect.position + Vector2(rect.size.x, 0)),
			transform._xform(rect.position + rect.size),
			transform._xform(rect.position + Vector2(0, rect.size.y))
		]
		for i in range(4):
			control.draw_line(arr[i], arr[(i + 1) % 4], Color.LIGHT_YELLOW)
			#? Select Handle
			var prev := (i + 3) % 4
			var next := (i + 1) % 4
			var ofs: Vector2 = ((arr[i] - arr[prev]).normalized() + ((arr[i] - arr[next]).normalized())).normalized()
			ofs *= sqrt(2) * (select_handle.get_size().x / 2)
			control.draw_texture(select_handle, (arr[i] + ofs - (select_handle.get_size() / 2)).floor())
			ofs = (arr[i] + arr[next]) / 2
			ofs += ((arr[next] - arr[i]).orthogonal().normalized() * floor(select_handle.get_size().x / 2))
			control.draw_texture(select_handle, (ofs - (select_handle.get_size() / 2)).floor())


func action_resize_node(node: Control, old_rect: Rect2, new_rect: Rect2, commit_action := true):
	undo_redo.create_action("Resize Node")
	undo_redo.add_undo_property(node, "position", old_rect.position)
	undo_redo.add_undo_property(node, "size", old_rect.size)
	undo_redo.add_undo_method(Callable(get_control_viewport(), "queue_redraw"))
	undo_redo.add_do_property(node, "position", new_rect.position)
	undo_redo.add_do_property(node, "size", new_rect.size)
	undo_redo.add_do_method(Callable(get_control_viewport(), "queue_redraw"))
	undo_redo.commit_action(commit_action)


func action_move_node(node: Control, from: Vector2, to: Vector2, commit_action := true):
	undo_redo.create_action("Move Node")
	undo_redo.add_undo_property(node, "position", from)
	undo_redo.add_undo_method(Callable(get_control_viewport(), "queue_redraw"))
	undo_redo.add_do_property(node, "position", to)
	undo_redo.add_do_method(Callable(get_control_viewport(), "queue_redraw"))
	undo_redo.commit_action(commit_action)


func action_select_node(node: Control):
	undo_redo.create_action("Select Node")
	undo_redo.add_undo_property(self, "selected", selected)
	undo_redo.add_do_property(self, "selected", node)
	undo_redo.commit_action()
