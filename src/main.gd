@tool
extends VBoxContainer

var popups = preload("res://src/popups.gd").new(self)
var top_menu = preload("res://src/top_menu.gd").new(popups)
var project_file: ConfigFile
var project_dir: DirAccess


func _init():
	MISC._prepare()
	add_child(top_menu, true, INTERNAL_MODE_FRONT)
	var cfg = MISC.get_editor_settings()
	# Set editor theme.
	var editor_theme = cfg.get_value("editor", "theme", "Default Dark")
	theme = MISC.get_editor_themes()[editor_theme]
	popups.theme = theme
	# Set editor font.
	var font_name = cfg.get_value("editor", "font", "Default")
	if MISC.THEME.has_font(font_name, "Fonts"):
		theme.default_font = MISC.THEME.get_font(font_name, "Fonts")
	# Set editor font size.
	theme.default_font_size = cfg.get_value("editor", "font_size", 16)
	# Validate recent project.
	if cfg.has_section_key("editor", "recent_project"):
		project_dir = DirAccess.open(cfg.get_value("editor", "recent_project"))
		if project_dir and project_dir.file_exists("project.cfg"):
			project_file = ConfigFile.new()
			if project_file.load(project_dir.get_current_dir() + "/project.cfg") != OK:
				print("ERROR: Can't load project file at: " + project_dir.get_current_dir())
				project_file = null
				project_dir = null


func _ready():
	get_parent().add_child.call_deferred(popups, true)
	if project_file:
		reload_project()


func _input(ev: InputEvent):
	if Engine.is_editor_hint():
		if not is_visible_in_tree():
			return
	if not (ev is InputEventKey and ev.pressed and not ev.echo):
		return
	if ev.keycode == KEY_S:
		if ev.ctrl_pressed:
			if ev.shift_pressed:
				popups.project_name_window.popup()
			else:
				save_project()
			get_viewport().set_input_as_handled()
	elif ev.keycode == KEY_Z:
		if ev.ctrl_pressed:
			if ev.shift_pressed:
				print("Undo")
			else:
				print("Redo")
			get_viewport().set_input_as_handled()


func save_project():
	print("Save")
	if project_file:
		project_file.save(project_dir.get_current_dir() + "/project.cfg.backup")
		if project_file.has_section("sprites"):
			project_file.erase_section("sprites")
		for sprite in get_node("%Sprites").get_children():
			project_file.set_value("sprites", sprite.name, sprite.get_data())
		project_file.set_value("camera", "position", get_node("%Camera").position)
		project_file.set_value("camera", "zoom", get_node("%Camera").zoom)
		if not OK == project_file.save(project_dir.get_current_dir() + "/project.cfg"):
			print("Warning: Can't save project file")
			MISC._prepare()
			popups.project_name_window.popup()
	else:
		popups.project_name_window.popup()


func reload_project():
	get_node("%Overlays").selected = null
	get_node("%Inspector").clear()
	var sprites_node = get_node("%Sprites")
	for spr in sprites_node.get_children():
		sprites_node.remove_child(spr)
		spr.queue_free()
	var sprite_box = get_node("%SpriteBox")
	for spr_button in sprite_box.get_children():
		sprite_box.remove_child(spr_button)
		spr_button.queue_free()
	if project_file.has_section("sprites"):
		for key in project_file.get_section_keys("sprites"):
			var sprite_data = project_file.get_value("sprites", key)
			var sprite = sprite_box.create_new_sprite(key)
			if sprite.load_data(sprite_data) != OK:
				print("ERROR: Can't load sprite: " + key)
			sprite_box.create_sprite_button(sprite)
	var camera = get_node("%Camera")
	camera.position = project_file.get_value("camera", "position", Vector2.ZERO)
	camera.zoom = project_file.get_value("camera", "zoom", Vector2(10, 10))
