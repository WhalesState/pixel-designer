extends GDScript


class SpriteButton:
    extends CheckerButton
    
    signal edit_sprite(spr)
    signal sprite_selected(spr_name, spr_size)

    var sprite: Dictionary
    var preview := TextureRect.new()
    var timer := Timer.new()
    var just_pressed := false
    
    
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
        # Timer
        timer.wait_time = 0.3
        timer.one_shot = true
        timer.timeout.connect(_on_timer_timeout)
        add_child(timer)
        pressed.connect(_on_sprite_pressed)
        toggled.connect(_on_button_toggled)
    
    
    func _on_sprite_pressed():
        if not just_pressed:
            just_pressed = true
            timer.start()
        else:
            just_pressed = false
            timer.stop()
            emit_signal("edit_sprite", sprite)
    
    
    func _on_timer_timeout():
        just_pressed = false
    
    
    func _on_button_toggled(_pressed: bool):
        if _pressed:
            emit_signal("sprite_selected", sprite["name"], sprite["size"])
