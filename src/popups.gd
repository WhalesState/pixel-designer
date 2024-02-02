@tool
extends Control

var main: VBoxContainer
var project_name_window: ProjectNameWindow
var editor_settings_window: EditorSettingsWindow
var projects_window: ProjectsWindow


func _init(main_node: VBoxContainer):
    name = "Popups"
    main = main_node
    size_flags_horizontal = SIZE_SHRINK_BEGIN
    size_flags_vertical = SIZE_SHRINK_BEGIN
    project_name_window = ProjectNameWindow.new(main)
    add_child(project_name_window)
    editor_settings_window = EditorSettingsWindow.new(main)
    add_child(editor_settings_window)
    projects_window = ProjectsWindow.new()
    add_child(projects_window)


class ProjectNameWindow:
    extends PopupWindow

    var main: VBoxContainer
    var name_line_edit := LineEdit.new()
    var warning_label := Label.new()
    var project_button := Button.new()
    var projects_dir: DirAccess
    var projects := PackedStringArray()


    func _init(_main: VBoxContainer):
        main = _main
        super._init()
        title = "Project Name"
        min_size = Vector2(256, 128)
        max_size = Vector2(640, 480)
        projects_dir = MISC.get_projects_dir()
        about_to_popup.connect(_on_about_to_popup)
        var vbox := VBoxContainer.new()
        margin.add_child(vbox)
        name_line_edit.placeholder_text = "Enter project name..."
        name_line_edit.max_length = 32
        name_line_edit.caret_blink = true
        name_line_edit.caret_blink_interval = 0.5
        name_line_edit.text_changed.connect(_on_project_name_changed)
        name_line_edit.custom_minimum_size = Vector2(0, 48)
        vbox.add_child(name_line_edit)
        warning_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
        warning_label.autowrap_mode = TextServer.AUTOWRAP_WORD
        warning_label.custom_minimum_size = Vector2(128, 32)
        warning_label.size_flags_vertical = Control.SIZE_EXPAND_FILL
        vbox.add_child(warning_label)
        project_button.text = "Save Project"
        project_button.custom_minimum_size = Vector2(0, 48)
        project_button.pressed.connect(_on_create_project_button_pressed)
        vbox.add_child(project_button)


    func _on_about_to_popup():
        name_line_edit.text = ""
        _on_project_name_changed(name_line_edit.text)
        projects = projects_dir.get_directories()
        for i in projects.size():
            projects[i] = projects[i].to_lower()


    func _on_project_name_changed(new_name: String):
        if new_name.is_valid_filename() and not projects.has(new_name.to_lower()):
            warning_label.text = "Project Ready!"
            warning_label.modulate = Color("66ff66")
            project_button.disabled = false
        else:
            if projects.has(new_name.to_lower()):
                warning_label.text = "Project with same name already exists!"
            else:
                warning_label.text = "Project Name is invalid!"
            warning_label.modulate = Color("ff3333")
            project_button.disabled = true


    func _on_create_project_button_pressed():
        if projects_dir.make_dir_recursive(name_line_edit.text) != OK:
            warning_label.text = "Can't create project directory!"
            return
        main.project_file = ConfigFile.new()
        main.project_dir = DirAccess.open("%s/%s" % [projects_dir.get_current_dir(), name_line_edit.text])
        if not main.project_dir:
            warning_label.text = "Can't open project directory!"
            return
        var cfg: ConfigFile = MISC.get_editor_settings()
        cfg.set_value("editor", "recent_project", main.project_dir.get_current_dir())
        MISC.save_editor_settings(cfg)
        main.save_project()
        hide()


class EditorSettingsWindow:
    extends PopupWindow
    
    var main: VBoxContainer
    var editor_settings: ConfigFile = MISC.get_editor_settings()
    var theme_options := OptionButton.new()
    var font_options := OptionButton.new()
    var font_size_spinbox := SpinBox.new()
    
    
    func _init(_main: VBoxContainer):
        main = _main
        super._init()
        title = "Editor Settings"
        unresizable = true
        min_size = Vector2(320, 0)
        max_size = Vector2(640, 480)
        about_to_popup.connect(_on_about_to_popup)
        about_to_hide.connect(_on_about_to_hide)
        var grid := GridContainer.new()
        grid.columns = 2
        grid.add_theme_constant_override("v_separation", 8)
        margin.add_child(grid)
        var theme_label := Label.new()
        theme_label.text = "Theme"
        theme_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        grid.add_child(theme_label)
        theme_options.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        var cur_theme = editor_settings.get_value("editor", "theme")
        for i in MISC.EDITOR_THEMES.keys().size():
            theme_options.add_item(MISC.EDITOR_THEMES.keys()[i], i)
            if not theme_options.selected:
                if MISC.EDITOR_THEMES.keys()[i] != cur_theme:
                    continue
                font_options.selected = i
        theme_options.item_selected.connect(_on_theme_options_item_selected)
        grid.add_child(theme_options)
        var font_label := Label.new()
        font_label.text = "Font"
        font_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        grid.add_child(font_label)
        font_options.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        var font_list = MISC.THEME.get_font_list("Fonts")
        var cur_font = editor_settings.get_value("editor", "font")
        for i in font_list.size():
            font_options.add_item(font_list[i], i)
            if not font_options.selected:
                if font_list[i] != cur_font:
                    continue
                font_options.selected = i
        font_options.item_selected.connect(_on_font_options_item_selected)
        grid.add_child(font_options)
        var font_size_label := Label.new()
        font_size_label.text = "Font Size"
        font_size_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        grid.add_child(font_size_label)
        font_size_spinbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        font_size_spinbox.suffix = "px"
        font_size_spinbox.min_value = 12
        font_size_spinbox.max_value = 32
        font_size_spinbox.step = 1
        font_size_spinbox.value = editor_settings.get_value("editor", "font_size", 16)
        font_size_spinbox.value_changed.connect(_on_font_size_spinbox_value_changed)
        grid.add_child(font_size_spinbox)
    
    
    func _on_theme_options_item_selected(id: int):
        var theme_name = theme_options.get_item_text(id)
        editor_settings.set_value("editor", "theme", theme_name)
        main.set_editor_theme(MISC.EDITOR_THEMES[theme_name])
        var font_name = editor_settings.get_value("editor", "font", "Default")
        main.theme.default_font = MISC.THEME.get_font(font_name, "Fonts")
        main.theme.default_font_size = editor_settings.get_value("editor", "font_size", 16)
        reset_size.call_deferred()
    
    
    func _on_font_options_item_selected(id: int):
        var font_name = font_options.get_item_text(id)
        if not MISC.THEME.has_font(font_name, "Fonts"):
            print("ERROR: Theme data doesn't have such font: %s" % font_name)
            return
        editor_settings.set_value("editor", "font", font_name)
        main.theme.default_font = MISC.THEME.get_font(font_name, "Fonts")
        reset_size.call_deferred()
    
    
    func _on_font_size_spinbox_value_changed(font_size: int):
        editor_settings.set_value("editor", "font_size", font_size)
        main.theme.default_font_size = font_size
        reset_size.call_deferred()
    
    
    func _on_about_to_popup():
        pass
    
    
    func _on_about_to_hide():
        if MISC.save_editor_settings(editor_settings) != OK:
            print("ERROR: Can't save editor settings file")


class ProjectsWindow:
    extends PopupWindow
    
    var projects_dir: DirAccess
    
    
    func _init():
        super._init()
        title = "Projects"
        min_size = Vector2(256, 128)
        max_size = Vector2(640, 480)
        projects_dir = MISC.get_projects_dir()
        about_to_popup.connect(_on_about_to_popup)
    
    
    func _on_about_to_popup():
        pass


class PopupWindow:
    extends Window
    
    signal about_to_hide
    
    var margin := MarginContainer.new()
    
    
    func _init():
        wrap_controls = true
        transient = true
        exclusive = true
        initial_position = Window.WINDOW_INITIAL_POSITION_CENTER_SCREEN_WITH_KEYBOARD_FOCUS
        close_requested.connect(_on_close_requested)
        visibility_changed.connect(_on_visibility_changed)
        margin.set_anchors_preset(Control.PRESET_FULL_RECT)
        for dir in ["left", "right", "top", "bottom"]:
            margin.add_theme_constant_override("margin_%s" % dir, 8)
        add_child(margin)
        hide()
    
    
    func _on_visibility_changed():
        if not visible:
            emit_signal("about_to_hide")
    
    
    func _on_close_requested():
        hide()
    
    
    func _input(ev: InputEvent):
        if not visible:
            return
        if ev.is_action_pressed("ui_cancel"):
            hide()
            get_viewport().set_input_as_handled()
