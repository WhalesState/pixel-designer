@tool
class_name Classes
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


class MaterialButton:
    extends CheckerButton
    
    signal material_pressed(mat_index: int, mat_colors: Array)
    signal material_moved(from: int, to: int)
    
    var texture := TextureRect.new()
    var material_colors := []:
        set(value):
            material_colors = value
            if not material_colors.size() == 4:
                print_debug("material data size != 4")
                return
            update_material_colors()
    
    
    func _init(mat: Array):
        super._init()
        texture.material = Global.MATERIAL_MATERIAL.duplicate()
        texture.texture = Global.MATERIAL_TEXTURE
        toggle_mode = true
        custom_minimum_size = Vector2i(48, 48)
        texture.set_anchors_and_offsets_preset(PRESET_FULL_RECT)
        toggled.connect(_on_button_toggled)
        add_child(texture)
        material_colors = mat
    
    
    func _on_button_toggled(_pressed: bool):
        if _pressed:
            emit_signal("material_pressed", get_node("../../../").get_index(), material_colors)
    
    
    func update_material_colors():
        # Outlines
        if material_colors[0].size() < 2:
            var outline_color = Color.TRANSPARENT if material_colors[0].size() == 0 else material_colors[0][0]
            set_color(0, outline_color)
            set_color(1, outline_color)
        else:
            for i in material_colors[0].size():
                set_color(i, material_colors[0][i])
        # Colors
        if material_colors[1].size() > 0:
            set_color(2, material_colors[1][0])
        var color = material_colors[1][0] if material_colors[1].size() < 2 else material_colors[1][1]
        set_color(3, color)
        if material_colors[1].size() > 2:
            color = material_colors[1][2]
        set_color(4, color)
        if material_colors[1].size() > 3:
            color = material_colors[1][3]
        set_color(5, color)
        color = material_colors[1][4] if material_colors[1].size() > 4 else get_color(2)
        set_color(6, color)
        color = material_colors[1][5] if material_colors[1].size() > 5 else get_color(3)
        set_color(7, color)
        # Highlight
        color = get_color(3) if material_colors[2].size() == 0 else material_colors[2][0]
        set_color(8, color)
        # Shadow
        color = Color.TRANSPARENT if material_colors[3].size() == 0 else material_colors[3][0]
        set_color(9, color)
    
    
    func set_color(ind: int, col: Color):
        texture.material.set_shader_parameter("col_%s" % ind, col)
    
    
    func get_color(ind: int) -> Color:
        return texture.material.get_shader_parameter("col_%s" % ind)
    
    
    func _get_drag_data(_pos: Vector2):
        var prev = TextureRect.new()
        prev.texture = texture.texture
        prev.material = texture.material.duplicate()
        prev.size = Vector2i(48, 48)
        set_drag_preview(prev)
        return self
    
    
    func _can_drop_data(_pos, data):
        if data.button_group == button_group and data != self:
            return true
        return false
    
    
    func _drop_data(_pos, data):
        emit_signal("material_moved", data.get_index(), get_index())


class Sprite:
    extends Sprite2D
    
    
    func _init():
        centered = false
        material = Global.SPRITE_MATERIAL
