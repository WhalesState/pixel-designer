@tool
extends Camera2D

var is_pan := false


func cam_zoom(value: int):
	if (zoom.x >= 10 and value > 0) or (zoom.x > 10 and value < 0):
		value *= 10
	var old_zoom := zoom.x
	var new_zoom := old_zoom + value
	new_zoom = clamp(new_zoom, 1, 150)
	var mpos = get_viewport().get_mouse_position()
	# .clamp(
	# 		vp_sprite.get_canvas_transform().origin,
	# 		vp_sprite.get_canvas_transform().origin + Vector2(viewport.size) * zoom
	# ).floor()
	var cur_pos = -get_viewport_rect().size / 2 + mpos
	zoom = Vector2(new_zoom, new_zoom)
	position -= cur_pos / new_zoom - cur_pos / old_zoom
	get_node("%Overlays").queue_redraw()


func focus_selected_sprite():
	var cur_spr_button = get_node("%SpriteBox").sprite_group.get_pressed_button()
	if cur_spr_button:
		var cur_spr = cur_spr_button.get_meta("node")
		position = cur_spr.position + (cur_spr.size / 2)


func _on_viewport_gui_input(ev: InputEvent):
	if not (ev is InputEventMouseMotion or ev is InputEventMouseButton):
		return
	if ev is InputEventMouseMotion and is_pan:
		position -= ev.relative / zoom
		get_viewport().set_input_as_handled()
		return
	if ev is InputEventMouseButton:
		if ev.button_index == MOUSE_BUTTON_MIDDLE:
			is_pan = ev.pressed
			get_viewport().set_input_as_handled()
		if ev.is_pressed():
			if ev.button_index == MOUSE_BUTTON_WHEEL_UP:
				cam_zoom(1)
				get_viewport().set_input_as_handled()
			elif ev.button_index == MOUSE_BUTTON_WHEEL_DOWN:
				cam_zoom(-1)
				get_viewport().set_input_as_handled()
