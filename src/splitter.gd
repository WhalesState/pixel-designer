@tool
class_name Splitter
extends Control

@export_range(4, 16, 2) var separation := 10:
	set(value):
		var new_sep = clamp(value, 4, 16)
		# Force even separation.
		if new_sep % 2 == 1:
			new_sep += 1
		if separation == new_sep:
			return
		separation = new_sep
		free_draggers()
		queue_redraw()

@export var vertical := false:
	set(value):
		if vertical == value:
			return
		vertical = value
		free_draggers()
		queue_redraw()

@export var autohide := true:
	set(value):
		if autohide == value:
			return
		autohide = value
		for dragger in draggers:
			dragger.autohide = autohide

var draggers := []
var children := []

var prev_size: Vector2


func _init():
	child_order_changed.connect(queue_redraw)


func _notification(what: int):
	if what in [NOTIFICATION_RESIZED, NOTIFICATION_ENTER_TREE, NOTIFICATION_THEME_CHANGED]:
		if prev_size != size and draggers.size() == children.size() - 1:
			for i in draggers.size():
				var dragger: Dragger = draggers[i]
				dragger.size[0 if vertical else 1] = size[0 if vertical else 1]
				move_dragger(dragger, i, true)
		prev_size = size
		queue_redraw()


# A Hack to call sort children once per frame using draw function.
func _draw():
	sort_children()


func sort_children():
	children.clear()
	# Get sortable children.
	for child in get_children():
		var c: Control = child as Control
		if not c or c is Dragger:
			continue
		if c.is_visible_in_tree():
			if not c.visibility_changed.is_connected(queue_redraw):
				c.visibility_changed.connect(queue_redraw)
			if not c.top_level:
				children.append(c)
	# Sort children.
	if children.size() == 0:
		free_draggers()
		custom_minimum_size = Vector2.ZERO
		return
	if children.size() == 1:
		free_draggers()
		children[0].position = Vector2.ZERO
		children[0].size = size
		custom_minimum_size = children[0].get_combined_minimum_size()
	else:
		var use_offsets = false
		var draggers_offset = []
		for child in children:
			if child.has_meta("dragger_offset"):
				draggers_offset.append(child.get_meta("dragger_offset"))
		if draggers_offset.size() >= children.size() - 1:
			use_offsets = true
		else:
			draggers_offset.clear()
		# Re-create draggers
		if draggers.size() != children.size() - 1:
			free_draggers()
			var child_size := Vector2.ZERO
			if not use_offsets:
				var _size = size
				_size[1 if vertical else 0] -= separation * (children.size() - 1)
				child_size = (_size / children.size()).floor()
			child_size[0 if vertical else 1] = size[0 if vertical else 1]
			var cur_pos := Vector2.ZERO
			for i in children.size():
				var child = children[i]
				child.position = cur_pos
				if i != children.size() - 1:
					if use_offsets:
						child_size[1 if vertical else 0] = (draggers_offset[i] * size[1 if vertical else 0]) - cur_pos[1 if vertical else 0]
					child.size = child_size
					var dragger := Dragger.new(separation, vertical)
					dragger.autohide = autohide
					add_child(dragger)
					move_child(dragger, child.get_index() + 1)
					dragger.move_dragger.connect(move_dragger.bind(dragger, i))
					draggers.append(dragger)
					var dragger_position = cur_pos + child_size
					dragger_position[0 if vertical else 1] = 0
					dragger.position = dragger_position
					var dragger_size = size
					dragger_size[1 if vertical else 0] = separation
					dragger.size = dragger_size
				else:
					child.size = size - cur_pos
				if use_offsets and i != children.size() - 1:
					cur_pos[1 if vertical else 0] = draggers_offset[i] * size[1 if vertical else 0] + separation
				else:
					cur_pos[1 if vertical else 0] += child_size[1 if vertical else 0] + separation
			# A hack to fix draggers position.
			for i in draggers.size():
				move_dragger(draggers[i], i, true)
		else:
			var cur_pos := Vector2.ZERO
			for i in draggers.size():
				var dragger = draggers[i]
				var child = children[i]
				child.position = cur_pos
				var child_size = size
				child_size[1 if vertical else 0] = (dragger.position - cur_pos)[1 if vertical else 0]
				child.size = child_size
				cur_pos = dragger.position + dragger.size
				# Insure zero.
				cur_pos[0 if vertical else 1] = 0
				if i == draggers.size() - 1:
					child = children[i + 1]
					child.position = cur_pos
					child.size = size - cur_pos
		var min_size = Vector2.ZERO
		for child in children:
			min_size += child.get_combined_minimum_size()
		min_size[1 if vertical else 0] += separation * draggers.size()
		custom_minimum_size = min_size


func free_draggers():
	for dragger in draggers:
		remove_child(dragger)
		if dragger.move_dragger.is_connected(move_dragger):
			dragger.move_dragger.disconnect(move_dragger)
		dragger.queue_free()
	draggers.clear()


func move_dragger(dragger: Dragger, idx: int, reset_pos:= false):
	var relative := Vector2.ZERO
	if not reset_pos:
		relative = get_local_mouse_position() - dragger.position
	var _min = 0
	var _max = size[1 if vertical else 0] - separation
	if idx > 0:
		_min = draggers[idx - 1].position[1 if vertical else 0] + separation
	_min = max(_min, _min + children[idx].get_combined_minimum_size()[1 if vertical else 0])
	if idx < draggers.size() - 1:
		_max = draggers[idx + 1].position[1 if vertical else 0] - separation
	_max = min(_max, _max - children[idx + 1].get_combined_minimum_size()[1 if vertical else 0])
	var new_pos = dragger.position[1 if vertical else 0] + relative[1 if vertical else 0]
	if not reset_pos:
		new_pos -= floor(separation / 2.0)
	else:
		new_pos = (dragger.position / (prev_size / size))[1 if vertical else 0]
	new_pos = clamp(new_pos, _min, _max)
	var pos := Vector2.ZERO
	pos[1 if vertical else 0] = new_pos
	if pos != dragger.position:
		dragger.position = pos
		children[idx].set_meta("dragger_offset", (dragger.position / size)[1 if vertical else 0])
		sort_children()


class Dragger:
	extends Control

	signal move_dragger()

	var separation: int:
		set(value):
			separation = clamp(value, 2, 16)
			queue_redraw()

	var autohide = true:
		set(value):
			if autohide == value:
				return
			autohide = value
			modulate = Color.TRANSPARENT if autohide else normal_color

	var vertical = false
	var is_dragging = false
	var mouse_in = false
	var normal_color := Color(0.498, 0.498, 0.498, 1.0)


	func _init(sep: int, is_vertical: bool):
		separation = sep
		vertical = is_vertical
		if autohide:
			modulate = Color.TRANSPARENT
		mouse_entered.connect(_mouse_io.bind(true))
		mouse_exited.connect(_mouse_io.bind(false))


	func _mouse_io(entered: bool) -> void:
		if autohide and not is_dragging:
			modulate = normal_color if entered else Color.TRANSPARENT
		var default_cursor = get_cursor_shape()
		mouse_default_cursor_shape = (CURSOR_VSIZE if vertical else CURSOR_HSIZE) if entered else default_cursor
		mouse_in = entered


	func _draw():
		var offset := Vector2(0.0 if vertical else (size.x - 4), (size.y - 4) if vertical else 0.0)
		draw_rect(Rect2(floor(offset / 2), size - offset), Color.WHITE)


	func _gui_input(event: InputEvent):
		var mb = event as InputEventMouseButton
		if mb and mb.button_index == MOUSE_BUTTON_LEFT:
			is_dragging = mb.pressed
			if is_dragging:
				modulate = get_tree().get_root().theme.accent_color
			else:
				if autohide:
					modulate = normal_color if mouse_in else Color.TRANSPARENT
				else:
					modulate = normal_color
			get_viewport().set_input_as_handled()
		var mm = event as InputEventMouseMotion
		if mm and is_dragging:
			move_dragger.emit()
			get_viewport().set_input_as_handled()
