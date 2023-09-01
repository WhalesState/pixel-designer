@tool
extends VBoxContainer

const GLOBAL = preload("./global.gd")

var sprite := {}:
    set(value):
        sprite = value
        update_sprite()

@onready var pixel_editor = get_node("%PixelEditor")
@onready var layers_tab: TabBox = get_node("%LayerTab")
@onready var anim_options: OptionButton = get_node("%AnimOptions")
@onready var anim_editor: PanelContainer = get_node("%AnimEditor")


func load_sprite(spr: Dictionary):
    sprite = spr
    pixel_editor.sprite.checker.image_size = sprite["size"]
    pixel_editor.camera._on_focus_camera_pressed()


func _ready():
    layers_tab.tab_changed.connect(_on_layer_tab_changed)
    layers_tab.tab_moved.connect(_on_layer_moved)
    anim_options.item_selected.connect(_on_anim_options_item_selected)


func _on_layer_tab_changed(ind: int):
    if sprite:
        print(ind)


func _on_anim_options_item_selected(ind: int):
    var cur_anim = anim_options.get_item_text(ind)
    get_node("%AnimLoop").button_pressed = sprite["animations"][cur_anim][1]
    anim_editor.cur_anim = sprite["animations"][anim_options.get_item_text(ind)]
    anim_editor.frame = 0


func update_sprite():
    get_node("%PreviewContainer").custom_minimum_size = Vector2(sprite["size"])
    get_node("%PreviewViewport").size =  Vector2(sprite["size"])
    update_layers()
    update_animations()


func update_animations():
    anim_options.clear()
    for anim in sprite["animations"].keys():
        anim_options.add_item(anim)
    anim_options.emit_signal("item_selected", 0)


func update_layers():
    layers_tab.clear()
    layers_tab.sprites = {}
    for layer in sprite["layers"]:
        var spr := GLOBAL.Sprite.new()
        var ind = layers_tab.add_layer(layer[0], spr)
        var container = layers_tab.get_container(ind)
        var button_group := ButtonGroup.new()
        for img in layer[1]:
            var cell_button := GLOBAL.CellButton.new(sprite["size"], img)
            cell_button.button_group = button_group
            cell_button.cell_pressed.connect(Callable(layers_tab, "_on_cell_button_pressed").bind(layer[0]))
            cell_button.cell_moved.connect(_on_cell_moved)
            container.add_child(cell_button)
        var cur_button: GLOBAL.CellButton = container.get_child(0)
        cur_button.button_pressed = true
        # Sprite
        spr.texture = cur_button.sprite.texture
        spr.hframes = cur_button.sprite.h_frames
        spr.vframes = cur_button.sprite.v_frames
        pixel_editor.sprite.add_child(spr)


func _on_layer_moved(from: int, to: int):
    var layer: Sprite2D = pixel_editor.sprite.get_child(from)
    pixel_editor.sprite.move_child(layer, to)
    var cur_layer: Array = sprite["layers"].pop_at(from)
    sprite["layers"].insert(to, cur_layer)


func _on_cell_moved(from: int, to: int):
    var container: HFlowContainer = layers_tab.get_container()
    var layer: GLOBAL.CellButton = container.get_child(from)
    container.move_child(layer, to)
    var cur_layer: Image = sprite["layers"][layers_tab.tab][1].pop_at(from)
    sprite["layers"][layers_tab.tab][1].insert(to, cur_layer)
