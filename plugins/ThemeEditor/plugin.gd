extends Plugin

var main_split: HSplitContainer

var preview: PanelContainer


func load_plugin() -> void:
	main_split = HSplitContainer.new()
	main_split.name = "ThemeEditor"
	var panel = PanelContainer.new()
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	panel.size_flags_stretch_ratio = 0.5
	main_split.add_child(panel)
	var inspector = ObjectInspector.new()
	panel.add_child(inspector)
	var editor_theme = EditorTheme.get_singleton()
	preview = load(get_path() + "/scene/theme_preview.tscn").instantiate()
	preview.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	preview.name = "ThemePreview"
	editor_theme.colors_changed.connect(func():
		preview.get_theme_stylebox("panel").bg_color = editor_theme._bg_color
	)
	main_split.add_child(preview)
	add_control_to_settings(main_split)
	await editor_theme.icons_changed
	inspector.edit(editor_theme)


func unload_plugin() -> void:
	remove_control_from_settings(main_split)
	main_split.free()


func get_plugin_info() -> String:
	return ""


func get_plugin_version() -> String:
	return "0.0.1"


func can_exit() -> bool:
	return true
