@tool
extends VBoxContainer

var sprite := {}:
    set(value):
        sprite = value
        update_sprite()

@onready var pixel_editor: VBoxContainer = get_node("%PixelEditor")
@onready var layers_tab: TabBox = get_node("%LayerTab")
@onready var materials_tab: TabBox = get_node("%MaterialTab")
@onready var colors_tab: TabBox = get_node("%ColorTab")
@onready var anim_options: OptionButton = get_node("%AnimOptions")
@onready var anim_editor: PanelContainer = get_node("%AnimEditor")


func load_sprite(spr: Dictionary):
    sprite = spr
    pixel_editor.sprite.checker.image_size = sprite["size"]
    pixel_editor.camera._on_focus_camera_pressed()


func _ready():
    anim_options.item_selected.connect(_on_anim_options_item_selected)
    pixel_editor.image_edited.connect(_on_image_edited)
    layers_tab.tab_moved.connect(_on_layer_tab_moved)
    materials_tab.tab_moved.connect(_on_material_tab_moved)
    colors_tab.color_button_pressed.connect(_on_color_button_pressed)
    # var img := Image.create(32, 1, false, Image.FORMAT_RGBA8)
    # for i in Global.SHADER_COLORS.size():
    #     img.set_pixel(i, 0, Global.SHADER_COLORS[i])
    # img.save_png("res://test.png")


func update_sprite():
    get_node("%PreviewContainer").custom_minimum_size = Vector2(sprite["size"])
    get_node("%PreviewViewport").size =  Vector2(sprite["size"])
    pixel_editor.helper_img = Image.create(sprite["size"].x, sprite["size"].y, false, Image.FORMAT_RGBA8)
    update_layers()
    update_materials()
    update_animations()


func update_layers():
    if layers_tab.tab_changed.is_connected(_on_layer_tab_changed):
        layers_tab.tab_changed.disconnect(_on_layer_tab_changed)
    layers_tab.clear()
    layers_tab.sprites = {}
    for layer in sprite["layers"]:
        var spr := Classes.Sprite.new()
        var ind = layers_tab.add_layer(layer[0], spr)
        var container = layers_tab.get_container(ind)
        var button_group := ButtonGroup.new()
        for img in layer[1]:
            var cell_button := Classes.CellButton.new(sprite["size"], img)
            cell_button.button_group = button_group
            cell_button.cell_pressed.connect(_on_cell_button_pressed.bind(layer[0]))
            cell_button.cell_moved.connect(_on_cell_moved)
            container.add_child(cell_button)
        var cur_button: Classes.CellButton = container.get_child(0)
        cur_button.set_pressed_no_signal(true)
        # Sprite
        spr.show_behind_parent = true
        spr.texture = cur_button.sprite.texture
        spr.hframes = cur_button.sprite.h_frames
        spr.vframes = cur_button.sprite.v_frames
        pixel_editor.sprite.add_child(spr)
    layers_tab.get_container().get_child(0).emit_signal("toggled", true)
    layers_tab.tab_changed.connect(_on_layer_tab_changed)
    layers_tab.emit_signal("tab_changed", 0)


func update_materials():
    if materials_tab.tab_changed.is_connected(_on_material_tab_changed):
        materials_tab.tab_changed.disconnect(_on_material_tab_changed)
    materials_tab.clear()
    for mat in sprite["materials"]:
        var ind = materials_tab.add_tab(mat[0])
        var container = materials_tab.get_container(ind)
        var material_group := ButtonGroup.new()
        for arr in mat[2][0]:
            var mat_button := Classes.MaterialButton.new(arr)
            mat_button.button_group = material_group
            mat_button.material_pressed.connect(_on_material_button_pressed)
            mat_button.material_moved.connect(_on_material_moved)
            container.add_child(mat_button)
        var cur_button: Classes.MaterialButton = container.get_child(0)
        cur_button.button_pressed = true
    materials_tab.tab_changed.connect(_on_material_tab_changed)
    materials_tab.tab = 0


func update_animations():
    anim_options.clear()
    for anim in sprite["animations"].keys():
        anim_options.add_item(anim)
    anim_options.emit_signal("item_selected", 0)


func _on_layer_tab_moved(from: int, to: int):
    var layer: Sprite2D = pixel_editor.sprite.get_child(from)
    pixel_editor.sprite.move_child(layer, to)
    var cur_layer: Array = sprite["layers"].pop_at(from)
    sprite["layers"].insert(to, cur_layer)


func _on_material_tab_moved(from: int, to: int):
    var cur_material: Array = sprite["materials"].pop_at(from)
    sprite["materials"].insert(to, cur_material)


func _on_cell_moved(from: int, to: int):
    var container: HFlowContainer = layers_tab.get_container()
    var layer: Classes.CellButton = container.get_child(from)
    container.move_child(layer, to)
    var cur_layer: Image = sprite["layers"][layers_tab.tab][1].pop_at(from)
    sprite["layers"][layers_tab.tab][1].insert(to, cur_layer)


func _on_material_moved(from: int, to: int):
    var container: HFlowContainer = materials_tab.get_container()
    var material_button: Classes.MaterialButton = container.get_child(from)
    container.move_child(material_button, to)
    var cur_mat: Array = sprite["materials"][materials_tab.tab][2][materials_tab.cur_palette].pop_at(from)
    sprite["materials"][materials_tab.tab][2][materials_tab.cur_palette].insert(to, cur_mat)


func _on_layer_tab_changed(ind: int):
    if sprite:
        pixel_editor.cur_layer = ind
        if layers_tab.tab > -1 and layers_tab.get_container().get_child(0):
            layers_tab.get_pressed_cell_button().emit_signal("toggled", true)


func _on_material_tab_changed(_ind: int):
    if sprite:
        if materials_tab.tab > -1 and materials_tab.get_container().get_child(0):
            materials_tab.get_pressed_material_button().emit_signal("toggled", true)


func _on_cell_button_pressed(texture: ImageTexture, layer_name: String):
    layers_tab.cur_cell = layers_tab.get_pressed_cell_button().get_index()
    layers_tab.sprites[layer_name].texture = texture
    pixel_editor.img = texture.get_image()


func _on_material_button_pressed(material_index: int, material_colors: Array):
    for i in material_colors.size():
        for j in material_colors[i].size():
            Global.SPRITE_MATERIAL.set_shader_parameter("col_%s" % sprite["materials"][material_index][1][i][j], Color(material_colors[i][j]))
            Global.CELL_MATERIAL.set_shader_parameter("col_%s" % sprite["materials"][material_index][1][i][j], Color(material_colors[i][j]))
        for j in range (colors_tab.get_container(i).get_child_count()):
            var col_button: MiniColorButton = colors_tab.get_container(i).get_child(j)
            col_button.size_flags_horizontal = SIZE_EXPAND_FILL
            if material_colors[i].size() - 1 >= j:
                col_button.disabled = false
                col_button.color = material_colors[i][j]
            else:
                col_button.disabled = true
                # col_button.size_flags_horizontal = SIZE_FILL
            # print(col_button)
    prints("material_colors :", material_colors, "material_index :", material_index)


func _on_color_button_pressed(col: Color):
    print(col)


func _on_image_edited(img: Image):
    layers_tab.get_container().get_child(layers_tab.cur_cell).sprite.texture = ImageTexture.create_from_image(img)


func _on_anim_options_item_selected(ind: int):
    var cur_anim = anim_options.get_item_text(ind)
    get_node("%AnimLoop").button_pressed = sprite["animations"][cur_anim][1]
    anim_editor.cur_anim = sprite["animations"][anim_options.get_item_text(ind)]
    anim_editor.frame = 0
