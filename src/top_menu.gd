@tool
extends HBoxContainer

enum {
	PROJECT_MENU,
	EDITOR_MENU,
}

enum PROJECT {
	NEW,
	OPEN,
	SAVE,
	SAVE_AS,
	SETTINGS,
	EXIT,
}

enum EDITOR {
	DATA_FOLDER,
	FULLSCREEN,
	ALWAYS_ON_TOP,
	SETTINGS,
}

const MENUS := {
	"Project": PROJECT_MENU,
	"Editor": EDITOR_MENU,
}

const ITEMS := {
	PROJECT_MENU: {
		"New Project": PROJECT.NEW,
		"Open Project": PROJECT.OPEN,
		"Save Project": PROJECT.SAVE,
		"Save Project As": PROJECT.SAVE_AS,
		"Project Settings": PROJECT.SETTINGS,
		"Exit": PROJECT.EXIT,
	},
	EDITOR_MENU: {
		"Open Data Folder": EDITOR.DATA_FOLDER,
		"Toggle Fullscreen": EDITOR.FULLSCREEN,
		"Toggle Always On Top": EDITOR.ALWAYS_ON_TOP,
		"Editor Settings": EDITOR.SETTINGS,
	},
}


func _ready() -> void:
	for child in get_children():
		remove_child(child)
		child.queue_free()
	for menu in MENUS.keys():
		var menu_button := MenuButton.new()
		menu_button.switch_on_hover = true
		menu_button.name = menu
		menu_button.text = menu
		menu_button.flat = false
		menu_button.focus_mode = FOCUS_ALL
		menu_button.get_popup().id_pressed.connect(_on_menu_id_pressed.bind(MENUS[menu]))
		add_child(menu_button)
		var menu_popup = menu_button.get_popup()
		for item in ITEMS[MENUS[menu]].keys():
			menu_popup.add_item(item, ITEMS[MENUS[menu]][item])


func _on_menu_id_pressed(item_id: int, menu_id: int) -> void:
	match menu_id:
		PROJECT_MENU:
			match item_id:
				PROJECT.NEW, PROJECT.SAVE_AS:
					get_node("%Popups").project_name_window.popup()
				PROJECT.OPEN:
					pass
				PROJECT.SAVE:
					get_parent().save_project()
				PROJECT.SETTINGS:
					pass
				PROJECT.EXIT:
					if Engine.is_editor_hint():
						return
					get_tree().quit()
		EDITOR_MENU:
			match item_id:
				EDITOR.DATA_FOLDER:
					MISC.open_user_data_dir()
				EDITOR.FULLSCREEN:
					MISC.toggle_fullscreen()
				EDITOR.ALWAYS_ON_TOP:
					if Engine.is_editor_hint():
						return
					MISC.toggle_always_on_top()
				EDITOR.SETTINGS:
					pass
