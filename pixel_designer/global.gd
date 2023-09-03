extends Object


class CellButton:
    extends CheckerButton
    
    signal cell_pressed(texture: ImageTexture)
    signal cell_moved(from: int, to: int)
    
    var sprite: TextureSprite
    
    
    func _init(spr_size: Vector2i, img: Image):
        super._init()
        toggle_mode = true
        custom_minimum_size = spr_size * 2
        sprite = TextureSprite.new(spr_size)
        sprite.texture = ImageTexture.create_from_image(img)
        sprite.set_anchors_and_offsets_preset(PRESET_FULL_RECT)
        add_child(sprite)
        toggled.connect(_on_button_toggled)
    
    
    func _on_button_toggled(_pressed: bool):
        if _pressed:
            emit_signal("cell_pressed", sprite.texture)
    
    
    func _get_drag_data(_pos: Vector2):
        var prev = TextureSprite.new(sprite.frame_size)
        prev.texture = sprite.texture
        prev.size = sprite.frame_size * 2
        set_drag_preview(prev)
        return self
    
    
    func _can_drop_data(_pos, data):
        if data.button_group == button_group and data != self:
            return true
        return false
    
    
    func _drop_data(_pos, data):
        emit_signal("cell_moved", data.get_index(), get_index())


class Sprite:
    extends Sprite2D
    
    
    func _init():
        centered = false
        material = Constants.SPRITE_MATERIAL
