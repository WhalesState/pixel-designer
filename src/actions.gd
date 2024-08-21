class_name Actions
extends Object

## For modifiers use KEY_MASK_CTRL, KEY_MASK_SHIFT and KEY_MASK_ALT.
## For keys use KEY_A or KEY_5 or KEY_DELETE or KEY_ESCAPE or KEY_F6.
## Example: add_action("SAVE_AS", KEY_MASK_CTRL | KEY_MASK_SHIFT | KEY_S)
## NOTE: Actions can only have one key alongside the modifiers.
## WARNING: If another action has the same action_name, nothing will happen.
## WARNING: If another action has the same action_key, it's key will be set to KEY_NONE.

signal action_map_changed()
signal action_pressed(action: String)

var actions := {}

static var singleton: Actions


static func get_singleton() -> Actions:
	return singleton


func add_action(action_name: String, action_key: int = KEY_NONE):
	if not actions.has(action_name):
		actions[action_name] = action_key
		action_map_changed.emit()


## WARNING: be careful while removing actions.
func remove_action(action_name: String):
	if action_name.begins_with("ED_"):
		return
	if actions.has(action_name):
		actions.erase(action_name)
		action_map_changed.emit()


func set_action_key(action_name: String, action_key: Key):
	if actions.has(action_name):
		var duplicate = actions.find_key(action_key)
		while duplicate:
			actions[duplicate] = KEY_NONE
			duplicate = actions.find_key(action_key)
		actions[action_name] = action_key
		action_map_changed.emit()


func _run_action(action_code: Key):
	if actions.values().has(action_code):
		var action_name = actions.find_key(action_code)
		action_pressed.emit(action_name)


func _store_actions():
	var file = FileAccess.open(OS.get_user_data_dir() + "/actions.map", FileAccess.WRITE)
	file.store_var(actions)
	file.close()


func _init() -> void:
	if FileAccess.file_exists(OS.get_user_data_dir() + "/actions.map"):
		var file = FileAccess.open(OS.get_user_data_dir() + "/actions.map", FileAccess.READ)
		actions = file.get_var()
		file.close()
	# Final pass.
	singleton = self
