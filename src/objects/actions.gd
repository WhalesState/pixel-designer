class_name Actions
extends Object

## Emits when actions are added, removed or changed.
signal action_map_changed()

## Emits when an action is pressed.
signal action_pressed(action: String)

## [b]PRIVATE[/b] stores all the project actions. [br]
## key = action_name: String [br]
## value = action_key: Key (mask | key) [br]
var _actions := {}

## [b]PRIVATE[/b] used for unique classes to easily access them with `ClassName.get_singleton()` from any other script.
static var _singleton: Actions

## Returns the current class unique instance. [br]
## Don't use this method for classes that will be instantiated more than once.
static func get_singleton() -> Actions:
	return _singleton


## Creates a new action if the action doesn't exist. [br]
## [b]WARNING[/b] if the action already exists, nothing will happen. [br]
## Example: [code]add_action("SAVE_AS", KEY_MASK_CTRL | KEY_MASK_SHIFT | KEY_S)[/code] [br]
## For modifiers use `KEY_MASK_CTRL`, `KEY_MASK_SHIFT` and `KEY_MASK_ALT`. [br]
## For keys use KEY_A or KEY_5 or KEY_DELETE or KEY_ESCAPE or KEY_F6. [br]
## [b]WARNING[/b] Actions can only have one key alongside the modifiers.
func add_action(action_name: String, action_key: int = KEY_NONE):
	if not _actions.has(action_name):
		_actions[action_name] = action_key
		action_map_changed.emit()


## Removes the action from the action map if exists.
func remove_action(action_name: String):
	if action_name.begins_with("ED_"):
		return
	if _actions.has(action_name):
		_actions.erase(action_name)
		action_map_changed.emit()


## Changes the action key if the action exists. [br]
## [b]WARNING[/b] If another action has the same action_name, nothing will happen. [br]
## [b]WARNING[/b] If another action has the same `action_key`, it's key will be changed to `KEY_NONE`.
func set_action_key(action_name: String, action_key: Key):
	if _actions.has(action_name):
		var duplicate = _actions.find_key(action_key)
		while duplicate:
			_actions[duplicate] = KEY_NONE
			duplicate = _actions.find_key(action_key)
		_actions[action_name] = action_key
		action_map_changed.emit()


## [b]PRIVATE[/b] Emits `action_pressed` signal if the action exists.
func _run_action(action_code: Key):
	if _actions.values().has(action_code):
		var action_name = _actions.find_key(action_code)
		action_pressed.emit(action_name)
		# print(OS.get_keycode_string(action_code))


## [b]PRIVATE[/b] Saves the current action map to user dir.
func _store_actions():
	var file = FileAccess.open(OS.get_user_data_dir() + "/actions.map", FileAccess.WRITE)
	file.store_var(_actions)
	file.close()


func _init() -> void:
	print_verbose("Actions _init()")
	if FileAccess.file_exists(OS.get_user_data_dir() + "/actions.map"):
		var file = FileAccess.open(OS.get_user_data_dir() + "/actions.map", FileAccess.READ)
		_actions = file.get_var()
		file.close()
	# Final pass.
	_singleton = self
