class_name PluginManager
extends PanelContainer

var vbox := VBoxContainer.new()

static var _singleton: PluginManager:
	set(value):
		if _singleton:
			return
		_singleton = value


func _update_plugins():
	for child in vbox.get_children():
		vbox.remove_child(child)
		child.queue_free()
	var editor := Editor.get_singleton()
	var plugin_list := editor._plugin_list
	if plugin_list.is_empty():
		return
	var plugin_names: PackedStringArray = plugin_list.keys()
	plugin_names.sort()
	for plugin_name in plugin_names:
		var plugin: Plugin = plugin_list[plugin_name]
		if plugin.is_internal():
			continue
		var button := CheckButton.new()
		button.toggle_mode = true
		button.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
		button.set_meta("_name", plugin_name)
		button.text = tr(plugin_name.capitalize())
		button.tooltip_text = tr(plugin_name.capitalize())
		if not plugin.get_plugin_info().is_empty():
			button.set_meta("_tooltip", plugin.get_plugin_info())
			button.tooltip_text += "\n" + tr(plugin.get_plugin_info())
		button.button_pressed = editor.is_plugin_enabled(plugin_name)
		button.toggled.connect(func(_pressed: bool):
			editor._set_plugin_enabled(plugin_name, _pressed)
		)
		vbox.add_child(button)


func _update_text():
	for child in vbox.get_children():
		var _name = child.get_meta("_name").capitalize()
		child.text = tr(_name)
		child.tooltip_text = tr(_name)
		if child.has_meta("_tooltip") and not child.get_meta("_tooltip").is_empty():
			child.tooltip_text += "\n" + tr(child.get_meta("_tooltip"))


func _update():
	var editor := Editor.get_singleton()
	for child in vbox.get_children():
		child.button_pressed = editor.is_plugin_enabled(child.get_meta("_name"))


static func get_singleton():
	return _singleton


func _notification(what: int) -> void:
	if what == NOTIFICATION_TRANSLATION_CHANGED:
		_update_text()
	elif what == NOTIFICATION_VISIBILITY_CHANGED:
		if visible:
			_update()


func _init() -> void:
	name = "PluginManager"
	var scroll = ScrollContainer.new()
	scroll.name = "PluginScroll"
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	add_child(scroll)
	vbox.name = "PluginVBox"
	vbox.size_flags_horizontal = SIZE_EXPAND_FILL
	vbox.size_flags_vertical = SIZE_EXPAND_FILL
	scroll.add_child(vbox)
	# Final pass.
	_singleton = self
