@tool 
extends HBoxContainer

enum {
	PROJECT_NEW,
	PROJECT_OPEN,
	PROJECT_SAVE,
	PROJECT_SAVE_AS,
	PROJECT_FOLDER,
	PROJECT_SETTINGS,
	PROJECT_EXIT,
	EDITOR_DATA_FOLDER,
	EDITOR_FULLSCREEN,
	# EDITOR_ALWAYS_ON_TOP,
	EDITOR_SETTINGS,
}

const MENUS := {
	"Project": {
		"New Project": PROJECT_NEW,
		"Open Project": PROJECT_OPEN,
		"Save Project": PROJECT_SAVE,
		"Save Project As": PROJECT_SAVE_AS,
		"Open Project Folder": PROJECT_FOLDER,
		"Project Settings": PROJECT_SETTINGS,
		"Exit": PROJECT_EXIT,
	},
	"Editor": {
		"Open Data Folder": EDITOR_DATA_FOLDER,
		"Toggle Fullscreen": EDITOR_FULLSCREEN,
		# "Toggle Always On Top": EDITOR_ALWAYS_ON_TOP,
		"Editor Settings": EDITOR_SETTINGS,
	},
}

var popups: Control


func _init(popups_node: Control):
	name = "TopMenu"
	popups = popups_node
	add_theme_constant_override("separation", 8)
	for menu in MENUS.keys():
		var menu_button := MenuButton.new()
		menu_button.switch_on_hover = true
		menu_button.name = menu
		menu_button.text = menu
		menu_button.flat = false
		menu_button.focus_mode = FOCUS_ALL
		var popup := menu_button.get_popup()
		popup.id_pressed.connect(_on_menu_id_pressed)
		popup.always_on_top = true
		add_child(menu_button)
		var menu_popup = menu_button.get_popup()
		for item in MENUS[menu].keys():
			menu_popup.add_item(item, MENUS[menu][item])


func _on_menu_id_pressed(item_id: int) -> void:
	match item_id:
		PROJECT_NEW, PROJECT_SAVE_AS:
			popups.project_name_window.popup()
		PROJECT_OPEN:
			pass
		PROJECT_SAVE:
			get_parent().save_project()
		PROJECT_SETTINGS:
			pass
		PROJECT_FOLDER:
			if (get_parent().project_dir):
				OS.shell_open(get_parent().project_dir.get_current_dir())
		PROJECT_EXIT:
			if Engine.is_editor_hint():
				return
			get_tree().quit()
		EDITOR_DATA_FOLDER:
			MISC.open_user_data_dir()
		EDITOR_FULLSCREEN:
			MISC.toggle_fullscreen()
		# EDITOR_ALWAYS_ON_TOP:
		# 	if Engine.is_editor_hint():
		# 		return
		# 	MISC.toggle_always_on_top()
		EDITOR_SETTINGS:
			popups.editor_settings_window.popup()
