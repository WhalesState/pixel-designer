extends GDScript


class LayerButton:
    extends CheckerButton
    
    var sprite: TextureSprite
    
    
    func _init(spr_size: Vector2i, img: Image):
        super._init()
        toggle_mode = true
        custom_minimum_size = spr_size * 2
        sprite = TextureSprite.new(spr_size)
        sprite.texture = ImageTexture.create_from_image(img)
        sprite.set_anchors_and_offsets_preset(PRESET_FULL_RECT)
        add_child(sprite)
