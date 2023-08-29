extends Object


class LayerButton:
    extends CheckerButton
    
    signal layer_pressed(texture: ImageTexture)
    
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
        if pressed:
            emit_signal("layer_pressed", sprite.texture)


class Sprite:
    extends Sprite2D
    
    
    func _init():
        centered = false
