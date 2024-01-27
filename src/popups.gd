@tool
extends Control

@onready var project_name_window := ProjectNameWindow.new()
@onready var editor_settings_window := EditorSettingsWindow.new()


func _ready():
    add_child(project_name_window)
    add_child(editor_settings_window)


class ProjectNameWindow:
    extends PopupWindow

    var name_line_edit := LineEdit.new()
    var warning_label := Label.new()
    var project_button := Button.new()
    var projects_dir: DirAccess
    var projects := PackedStringArray()


    func _init():
        super._init()
        title = "Project Name"
        min_size = Vector2(256, 128)
        max_size = Vector2(640, 480)
        initial_position = WINDOW_INITIAL_POSITION_CENTER_SCREEN_WITH_KEYBOARD_FOCUS
        projects_dir = MISC.get_projects_dir()
        about_to_popup.connect(_on_about_to_popup)
        var margin := MarginContainer.new()
        margin.set_anchors_preset(Control.PRESET_FULL_RECT)
        for dir in ["left", "right", "top", "bottom"]:
            margin.add_theme_constant_override("margin_%s" % dir, 8)
        add_child(margin)
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
        var main: VBoxContainer = get_parent().get_parent().get_node("Main")
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
    
    
    func _init():
        super._init()
        title = "Editor Settings"
        about_to_hide.connect(_on_about_to_hide)
    
    
    func _on_about_to_hide():
        var cfg = MISC.get_editor_settings()
        # TODO: Save editor settings!
        if MISC.save_editor_settings(cfg) != OK:
            print("ERROR: Can't save editor settings file")
