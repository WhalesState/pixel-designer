@tool
class_name MISC

const DS_FULLSCREEN = DisplayServer.WINDOW_MODE_FULLSCREEN
const DS_WINDOWED = DisplayServer.WINDOW_MODE_WINDOWED
# const DS_ALWAYS_ON_TOP = DisplayServer.WINDOW_FLAG_ALWAYS_ON_TOP

const SPRITE_MATERIAL: CanvasItemMaterial = preload("res://constants/sprite_material.tres")

const THEME: Theme = preload("res://theme/data/theme.tres")

const EDITOR_THEMES: Dictionary = {
	"Default Dark": preload("res://theme/default_dark.tres"),
}

static func _prepare() -> void:
	var dir = DirAccess.open(OS.get_user_data_dir())
	if not dir:
		print("ERROR: Can't access user directory")
		return
	if not dir.dir_exists("projects"):
		if dir.make_dir_recursive("projects") != OK:
			print("ERROR: Can't create projects directory")
	if not dir.file_exists("editor_settings.cfg"):
		if save_editor_settings(get_editor_settings()) != OK:
			print("ERROR: Can't save editor settings")
	var fonts := get_editor_fonts()
	for font in fonts.keys():
		if not THEME.has_font(font, "Fonts"):
			THEME.set_font(font, "Fonts", fonts[font])


static func open_user_data_dir() -> void:
	OS.shell_open(OS.get_user_data_dir())


static func toggle_fullscreen() -> void:
	var is_fullscreen = true if DisplayServer.window_get_mode() == DS_FULLSCREEN else false
	var mode = DS_WINDOWED if is_fullscreen else DS_FULLSCREEN
	DisplayServer.window_set_mode(mode)


# static func toggle_always_on_top() -> void:
# 	var is_always_on_top = DisplayServer.window_get_flag(DS_ALWAYS_ON_TOP)
# 	DisplayServer.window_set_flag(DS_ALWAYS_ON_TOP, not is_always_on_top)


static func get_projects_dir() -> DirAccess:
	var project_dir = DirAccess.open(OS.get_user_data_dir())
	if not project_dir.dir_exists("projects"):
		print("Warning: Project dir doesn't exists, creating...")
		if not OK == project_dir.make_dir_recursive("projects"):
			print("ERROR: Can't create projects directory!")
			return
	if not OK == project_dir.change_dir("projects"):
		print("ERROR: Can't access projects directory!")
	return project_dir


static func get_editor_fonts() -> Dictionary:
	var fonts := {}
	var fonts_dir = DirAccess.open("res://theme/data/fonts")
	if not fonts_dir:
		print("ERROR: Can't open fonts dir!")
	var files = fonts_dir.get_files()
	for font_file in files:
		if not font_file.get_extension() == "ttf":
			continue
		fonts[font_file.get_basename()] = load("%s/%s" % [fonts_dir.get_current_dir(), font_file])
	return fonts


static func save_editor_settings(cfg: ConfigFile) -> int:
	return cfg.save(OS.get_user_data_dir() + "/editor_settings.cfg")


static func get_editor_settings() -> ConfigFile:
	var dir = DirAccess.open(OS.get_user_data_dir())
	var cfg := ConfigFile.new()
	if not dir.file_exists("editor_settings.cfg"):
		cfg.set_value("editor", "theme", "Default Dark")
		cfg.set_value("editor", "font", "Default")
		cfg.set_value("editor", "font_size", 16)
	else:
		if cfg.load(OS.get_user_data_dir() + "/editor_settings.cfg") != OK:
			print("ERROR: Can't load editor settings")
	return cfg


static func get_icon(icon_name: String) -> Texture2D:
	if THEME.has_icon(icon_name, "Icons"):
		return THEME.get_icon(icon_name, "Icons")
	return Texture2D.new()
