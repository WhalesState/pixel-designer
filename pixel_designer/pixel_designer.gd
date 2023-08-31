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
    layers_tab.replace_tabs.connect(_on_layer_tab_replaced)
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
    update_layers()
    update_animations()


func update_animations():
    anim_options.clear()
    for anim in sprite["animations"].keys():
        anim_options.add_item(anim)
    anim_options.emit_signal("item_selected", 0)


func update_layers():
    layers_tab.clear()
    for layer in sprite["layers"]:
        var spr := GLOBAL.Sprite.new()
        var ind = layers_tab.add_layer(layer[0], spr)
        var container = layers_tab.get_container(ind)
        var button_group := ButtonGroup.new()
        for img in layer[1]:
            var layer_button := GLOBAL.LayerButton.new(sprite["size"], img)
            layer_button.button_group = button_group
            layer_button.layer_pressed.connect(Callable(layers_tab, "_on_layer_button_pressed").bind(layer[0]))
            container.add_child(layer_button)
        var cur_button: GLOBAL.LayerButton = container.get_child(0)
        cur_button.button_pressed = true
        # Sprite
        await get_tree().process_frame
        spr.texture = cur_button.sprite.texture
        spr.hframes = cur_button.sprite.h_frames
        spr.vframes = cur_button.sprite.v_frames
        spr.material = Constants.SPRITE_MATERIAL
        pixel_editor.sprite.add_child(spr)
        get_node("%PreviewContainer").custom_minimum_size = Vector2(sprite["size"])
        get_node("%PreviewViewport").size =  Vector2(sprite["size"])


func _on_layer_tab_replaced(from: int, to: int):
    var layer: Sprite2D = pixel_editor.sprite.get_child(from)
    pixel_editor.sprite.move_child(layer, to)
    var arr: Array = sprite["layers"][from]
    sprite["layers"][from] = sprite["layers"][to]
    sprite["layers"][to] = arr
