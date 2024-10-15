extends Plugin

var main_vbox: VBoxContainer

var preview: PanelContainer


func load_plugin() -> void:
	main_vbox = VBoxContainer.new()
	main_vbox.name = "ThemeEditor"
	var top_hbox := HBoxContainer.new()
	top_hbox.name = "TopHBox"
	main_vbox.add_child(top_hbox)
	var colors_panel := PanelContainer.new()
	colors_panel.name = "ColorsPanel"
	colors_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var colors_panel_style = StyleBoxFlat.new()
	colors_panel_style.draw_center = false
	colors_panel_style.set_border_width_all(2)
	colors_panel.add_theme_stylebox_override("panel", colors_panel_style)
	top_hbox.add_child(colors_panel)
	var colors_hbox := HBoxContainer.new()
	colors_hbox.name = "ColorsHBox"
	colors_panel.add_child(colors_hbox)
	colors_hbox.add_theme_constant_override("separation", 0)
	var col_names := PackedStringArray(["primary_color", "secondary_color", "background_color", "primary_color_2", "primary_color_3", "primary_color_4", "secondary_color_2"])
	for i in 7:
		var color_rect = ColorRect.new()
		color_rect.name = col_names[i].to_pascal_case()
		color_rect.tooltip_text = col_names[i].capitalize()
		color_rect.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		colors_hbox.add_child(color_rect)
	var editor_theme = EditorTheme.get_singleton()
	var preview_button := CheckBox.new()
	preview_button.name = "PreviewButton"
	preview_button.tooltip_text = "Toggle Preview"
	editor_theme.add_to_icon_queue(preview_button, "theme_override_icons/checked", "Show")
	editor_theme.add_to_icon_queue(preview_button, "theme_override_icons/unchecked", "Hide")
	top_hbox.add_child(preview_button)
	var main_split = HSplitContainer.new()
	main_split.name = "HSplit"
	main_split.size_flags_vertical = Control.SIZE_EXPAND_FILL
	main_vbox.add_child(main_split)
	var panel = PanelContainer.new()
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	panel.size_flags_stretch_ratio = 0.5
	main_split.add_child(panel)
	var inspector = ObjectInspector.new()
	panel.add_child(inspector)
	preview = load(get_path() + "/scene/theme_preview.tscn").instantiate()
	preview.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	preview.name = "ThemePreview"
	preview_button.toggled.connect(func(toggled_on):
		preview.visible = toggled_on
	)
	editor_theme.colors_changed.connect(func():
		preview.get_theme_stylebox("panel").bg_color = editor_theme._bg_color
		colors_panel_style.border_color = editor_theme._font_color
		colors_hbox.get_child(0).color = editor_theme.primary_color
		colors_hbox.get_child(1).color = editor_theme.secondary_color
		colors_hbox.get_child(2).color = editor_theme._bg_color
		colors_hbox.get_child(3).color = editor_theme._primary_color2
		colors_hbox.get_child(4).color = editor_theme._primary_color3
		colors_hbox.get_child(5).color = editor_theme._primary_color4
		colors_hbox.get_child(6).color = editor_theme._secondary_color2
	)
	main_split.add_child(preview)
	preview.hide()
	add_control_to_settings(main_vbox, "Palette", get_plugin_info())
	await editor_theme.icons_changed
	inspector.edit(editor_theme)


func unload_plugin() -> void:
	remove_control_from_settings(main_vbox)
	main_vbox.free()


func get_plugin_info() -> String:
	return "Allows you to edit the editor theme."


func get_plugin_version() -> String:
	return "0.0.1"
