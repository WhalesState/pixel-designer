extends GDScript


class SpriteButton:
    extends CheckerButton
    
    signal edit_sprite(spr)
    signal sprite_selected(spr_name, spr_size)

    var sprite: Dictionary
    var preview := TextureRect.new()
    
    
    func update_preview():
        preview.texture = ImageTexture.create_from_image(sprite["preview"])
    
    
    func _init(spr: Dictionary, spr_group: ButtonGroup):
        super._init()
        custom_minimum_size = Vector2i(128, 128)
        toggle_mode = true
        button_group = spr_group
        sprite = spr
        # Preview
        preview.set_anchors_and_offsets_preset(PRESET_FULL_RECT)
        add_child(preview)
        update_preview()
        toggled.connect(_on_button_toggled)
    
    
    func _gui_input(ev: InputEvent):
        if not (ev is InputEventMouseButton and ev.is_pressed()):
            return
        if ev.double_click:
            emit_signal("edit_sprite", sprite)
            get_viewport().set_input_as_handled()
    
    
    func _on_button_toggled(_pressed: bool):
        if _pressed:
            emit_signal("sprite_selected", sprite["name"], sprite["size"])
