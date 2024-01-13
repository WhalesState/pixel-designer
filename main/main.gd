@tool
extends TabContainer

# const Global = preload("./global.gd")
#const CLASS = preload("./classes.gd")


func _init():
    if Global.is_first_run():
        var err = Global.save_sprite(Global.get_default_character())
        print_debug("Save Default Character sprite: %s" % (err == OK))
    # Force update the defualt character on start
    # TODO: Remove this.
    var test_err = Global.save_sprite(Global.get_default_character())
    print_debug("Save Default Character sprite: %s" % (test_err == OK))


func _ready():
    # Root
    get_tree().get_root().min_size = Vector2i(640, 480)
    get_tree().get_root().close_requested.connect(_on_close_requested)
    # Tool
    $"%VersionButton".text = "Pixel Designer v%s" % Global.VERSION
    reload_sprites()


func reload_sprites():
    var sprites_flow = get_node("%SpritesFlow")
    for spr in sprites_flow.get_children():
        sprites_flow.remove_child(spr)
        spr.queue_free()
    var sprites = Global.get_saved_sprites()
    for spr in sprites.values():
        var new_spr = Classes.SpriteButton.new(spr, Global.SPRITES_GROUP)
        new_spr.tooltip_text = "%s %s" % [spr["name"], spr["size"]]
        new_spr.edit_sprite.connect(_on_edit_sprite)
        new_spr.sprite_selected.connect(_on_sprite_selected)
        sprites_flow.add_child(new_spr)
    sprites_flow.get_child(0).button_pressed = true


func _on_edit_sprite(spr: Dictionary):
    current_tab = 1
    $PixelDesigner.load_sprite(spr)


func _on_sprite_selected(spr_name: String, spr_size: Vector2i):
    get_node("%SpriteName").text = "Name: %s , Size: %s" % [spr_name, spr_size]


func _on_close_requested():
    print_debug("close!")
    pass
