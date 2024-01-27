@tool
extends Container

@export_range(0.0, 1.0) var left_ofc := 0.25:
	set(value):
		left_ofc = clamp(value, (sep / 2.0) / size.x, right_ofc - (sep / 2.0) / size.x)
		update_layout()

@export_range(0.0, 1.0) var right_ofc := 0.75:
	set(value):
		right_ofc = clamp(value, left_ofc + (sep / 2.0) / size.x, 1 - (sep / 2.0) / size.x)
		update_layout()

@export_range(0.0, 1.0) var bottom_ofc := 0.6:
	set(value):
		bottom_ofc = clamp(value, (sep / 2.0) / size.y, 1 - (sep / 2.0) / size.y)
		update_layout()

@export_range(6, 16, 2) var sep := 8:
	set(value):
		sep = value
		update_layout()

@export var dragger_color := Color(0.4, 0.6, 1, 0.8)

var cur_ofc := ""
var is_drag := false

@onready var left = get_node("LeftContainer")
@onready var center = get_node("CenterContainer")
@onready var bottom = get_node("BottomContainer")
@onready var right = get_node("RightContainer")


func _notification(what: int):
	if what == NOTIFICATION_SORT_CHILDREN:
		update_layout()
	elif what == NOTIFICATION_MOUSE_EXIT:
		if is_drag:
			return
		if not cur_ofc.is_empty():
			cur_ofc = ""
			queue_redraw()
	elif what == NOTIFICATION_DRAW:
		if cur_ofc == "left":
			draw_line(
				Vector2(floor(size.x * left_ofc), 0),
				Vector2(floor(size.x * left_ofc), size.y),
				dragger_color,
				4
			)
			mouse_default_cursor_shape = CURSOR_HSPLIT
		elif cur_ofc == "right":
			draw_line(
				Vector2(floor(size.x * right_ofc), 0),
				Vector2(floor(size.x * right_ofc), size.y),
				dragger_color,
				4
			)
			mouse_default_cursor_shape = CURSOR_HSPLIT
		elif cur_ofc == "bottom":
			draw_line(
				Vector2(left.size.x, floor(size.y * bottom_ofc)),
				Vector2(right.position.x, floor(size.y * bottom_ofc)),
				dragger_color,
				4
			)
			mouse_default_cursor_shape = CURSOR_VSPLIT
		else:
			mouse_default_cursor_shape = CURSOR_ARROW


func _gui_input(ev: InputEvent):
	if not (ev is InputEventMouseButton or ev is InputEventMouseMotion):
		return
	if ev is InputEventMouseMotion:
		if is_drag:
			var mp = get_local_mouse_position()
			if cur_ofc == "left":
				left_ofc = mp.x / size.x
			elif cur_ofc == "right":
				right_ofc = mp.x / size.x
			elif cur_ofc == "bottom":
				bottom_ofc = mp.y / size.y
			queue_redraw()
			return
		var pos = ev.position
		if pos.x >= left.size.x and pos.x <= center.position.x:
			if cur_ofc != "left":
				cur_ofc = "left"
				queue_redraw()
		elif pos.x >= center.position.x + center.size.x and pos.x <= right.position.x:
			if cur_ofc != "right":
				cur_ofc = "right"
				queue_redraw()
		elif (
			pos.x > left.size.x
			and pos.x < right.position.x
			and pos.y >= center.size.y
			and pos.y <= bottom.position.y
		):
			if cur_ofc != "bottom":
				cur_ofc = "bottom"
				queue_redraw()
		else:
			if cur_ofc != "":
				cur_ofc = ""
				queue_redraw()
	elif ev is InputEventMouseButton and ev.button_index == MOUSE_BUTTON_LEFT:
		if ev.double_click:
			if cur_ofc != "":
				if cur_ofc == "left":
					left_ofc = 0
				elif cur_ofc == "right":
					right_ofc = 1
				elif cur_ofc == "bottom":
					bottom_ofc = 1
				cur_ofc = ""
				queue_redraw()
		if ev.is_pressed():
			if cur_ofc != "":
				is_drag = true
		else:
			if is_drag:
				is_drag = false
			if cur_ofc != "":
				if not Rect2(position, size).has_point(ev.position):
					cur_ofc = ""
					queue_redraw()
					return
			var pos = ev.position
			if cur_ofc == "left" and not (pos.x >= left.size.x and pos.x <= center.position.x):
				cur_ofc = ""
				queue_redraw()
			elif (
				cur_ofc == "right"
				and not (pos.x >= center.position.x + center.size.x and pos.x <= right.position.x)
			):
				cur_ofc = ""
				queue_redraw()
			elif (
				cur_ofc == "bottom"
				and not (
					pos.x > left.size.x
					and pos.x < right.position.x
					and pos.y >= center.size.y
					and pos.y <= bottom.position.y
				)
			):
				cur_ofc = ""
				queue_redraw()


func update_layout():
	if not (left and right and bottom and center):
		return
	var h_sep = sep / 2.0
	var d_sep = sep * 2
	fit_child_in_rect(left, Rect2(0, 0, floor(size.x * left_ofc) - h_sep, size.y))
	fit_child_in_rect(
		right,
		Rect2(
			floor(size.x * right_ofc) + h_sep,
			0,
			size.x - floor(size.x * right_ofc) - h_sep,
			size.y
		)
	)
	fit_child_in_rect(
		bottom,
		Rect2(
			left.size.x + sep,
			floor(size.y * bottom_ofc) + h_sep,
			size.x - (left.size.x + right.size.x) - d_sep,
			size.y - floor(size.y * bottom_ofc) - h_sep
		)
	)
	fit_child_in_rect(
		center,
		Rect2(
			left.size.x + sep,
			0,
			size.x - (left.size.x + right.size.x) - d_sep,
			size.y - bottom.size.y - sep
		)
	)
