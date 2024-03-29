@tool
class_name Global
extends Object

const VERSION := "1.1.alpha"

const SPRITES_GROUP: ButtonGroup = preload("./groups/sprites_group.tres")
const CELL_MATERIAL: Material = preload("./constants/cell_button_material.tres")
const SPRITE_MATERIAL: Material = preload("./constants/sprite_material.tres")
const MATERIAL_MATERIAL: Material = preload("./constants/material_button_material.tres")
const MATERIAL_TEXTURE: CompressedTexture2D = preload("./constants/material.png")

const SHADER_COLORS: PackedColorArray = [
    Color(0.0, 0.0, 0.0, 1.0), # 0 black # skin outline
    Color(1.0, 0.0, 0.0, 1.0), # 1 red   # skin color
    Color(0.0, 1.0, 0.0, 1.0), # 2 green # skin shade
    Color(0.0, 0.0, 1.0, 1.0), # 3 blue # eyes color
    Color(0.2, 0.2, 0.2, 1.0), # 4 dark gray # clothes outline
    Color(0.0, 1.0, 1.0, 1.0), # 5 cyan      # clothes color
    Color(1.0, 0.0, 1.0, 1.0), # 6 magneta   # clothes shade
    Color(1.0, 1.0, 0.0, 1.0), # 7 yellow    # clothes highlight
    Color(0.6, 0.0, 0.0, 1.0), # 8 maroon  # hair outline
    Color(0.4, 0.4, 0.4, 1.0), # 9 gray    # hair color
    Color(0.4, 0.0, 1.0, 1.0), # 10 Purple # hair shade
    Color(1.0, 0.4, 0.0, 1.0), # 11 Orange # hair dark shade
    Color(0.0, 0.6, 0.0, 1.0), # 12 dark green # item outline
    Color(0.8, 0.8, 0.8, 1.0), # 13 silver     # item color
    Color(0.6, 0.6, 0.0, 1.0), # 14 olive      # item shade
    Color(1.0, 0.6, 0.0, 1.0), # 15 orange-ish # item dark shade
    Color(0.6, 0.0, 0.6, 1.0), # 16 purple-ish # metal outline
    Color(0.0, 0.6, 0.6, 1.0), # 17 teal       # metal color
    Color(0.0, 0.0, 0.6, 1.0), # 18 navy       # metal shade
    Color(1.0, 1.0, 0.6, 1.0), # 19 light yellow # B&W black
    Color(0.6, 1.0, 0.0, 1.0), # 20 lime green   # B&W white
    Color(0.0, 1.0, 0.6, 1.0), # 21 spring green # mask outline
    Color(0.6, 0.0, 1.0, 1.0), # 22 violet       # mask color
    Color(0.0, 0.6, 1.0, 1.0), # 23 sky blue     # mask shade
    Color(1.0, 0.6, 0.4, 1.0), # 24 light orange
    Color(1.0, 0.0, 0.6, 1.0), # 25 rose
    Color(1.0, 0.8, 0.8, 1.0), # 26 pink
    Color(0.0, 0.8, 0.8, 1.0), # 27 aqua
    Color(1.0, 0.4, 0.2, 1.0), # 28 tomatoe
    Color(1.0, 0.8, 0.0, 1.0), # 29 gold
    Color(0.6, 0.2, 0.2, 1.0), # 30 brown
    Color(1.0, 1.0, 1.0, 1.0),  # 31 white
]

const MATERIAL_COLORS: PackedColorArray = [
    Color(0.0, 0.0, 0.0, 1.0), # 0 black     # primary outline
    Color(0.2, 0.2, 0.2, 1.0), # 1 dark gray # secondary outline
    Color(0.0, 0.0, 1.0, 1.0), # 2 blue
    Color(1.0, 0.0, 0.0, 1.0), # 3 red
    Color(0.0, 1.0, 0.0, 1.0), # 4 green
    Color(1.0, 0.0, 1.0, 1.0), # 5 magenta
    Color(1.0, 1.0, 0.0, 1.0), # 6 yellow
    Color(0.0, 1.0, 1.0, 1.0), # 7 cyan
    Color(1.0, 1.0, 1.0, 1.0), # 8 white    # highlight
    Color(0.4, 0.4, 0.4, 1.0),  # 9 gray     # shadow
]


static func get_sprites_path() -> String:
    var dir := DirAccess.open(OS.get_user_data_dir())
    if not dir.dir_exists("data"):
        dir.make_dir("data")
    dir.change_dir("data")
    if not dir.dir_exists("sprites"):
        dir.make_dir("sprites")
    dir.change_dir("sprites")
    return dir.get_current_dir()


static func is_first_run() -> bool:
    return not DirAccess.dir_exists_absolute("%s/data" % OS.get_user_data_dir())


static func save_sprite(sprite: Dictionary, path := "") -> int:
    if path.is_empty():
        path = get_sprites_path()
    if not DirAccess.dir_exists_absolute(path):
        print_debug("ERROR: Invalid Sprite Path!")
        return ERR_FILE_BAD_PATH
    if not sprite:
        print_debug("ERROR: Invalid Sprite Data!")
        return ERR_INVALID_DATA
    var spr_name: String = sprite["name"]
    spr_name = spr_name.replace(" ", "_")
    if not spr_name.is_valid_filename():
        print_debug("ERROR: Invalid Sprite Name!")
        return ERR_INVALID_PARAMETER
    var file := FileAccess.open("%s/%s.pds" % [path, spr_name], FileAccess.WRITE)
    file.store_var(sprite, true)
    file.close()
    # var cfg := ConfigFile.new()
    # cfg.set_value("sprite", "name", sprite["name"])
    # cfg.set_value("sprite", "author", "Pixel Designer")
    # cfg.set_value("sprite", "version", "1.0")
    # cfg.set_value("sprite", "size", sprite["size"])
    # cfg.set_value("sprite", "animations", sprite["animations"])
    # cfg.set_value("sprite", "materials", sprite["materials"])
    # cfg.set_value("sprite", "material_ids", sprite["material_ids"])
    # cfg.save("%s/sprite.cfg" % get_sprites_path())
    return OK


static func create_new_sprite(spr_name: String, spr_size: Vector2i) -> int:
    var img := Image.create(spr_size.x, spr_size.y, false, Image.FORMAT_RGBA8)
    var sprite := {
        "name": spr_name,
        "size": spr_size,
        "animations": {"Default": [[0], false]},
        "material_ids": {"const": [0, 1]},
        "materials": {"const": [["000000ff", "ffffffff"]]},
        "layers": [["default", [img]]],
        "preview": img.duplicate(),
    }
    return save_sprite(sprite)


static func get_default_character() -> Dictionary:
    var images_path := "res://main/default_character"
    # Sprite defaults
    var cfg = ConfigFile.new()
    var err = cfg.load("%s/sprite.cfg" % images_path)
    print()
    if err != OK:
        print_debug("Can't load default character config file!")
        return {}
    var sprite := {
        "name": cfg.get_value("sprite", "name"),
        "author": cfg.get_value("sprite", "author"),
        "version": cfg.get_value("sprite", "version"),
        "size": cfg.get_value("sprite", "size"),
        "animations": cfg.get_value("sprite", "animations"),
        "materials": cfg.get_value("sprite", "materials"),
        "layers": [],
        "preview": null,
    }
    # Layers
    var dir := DirAccess.open(images_path)
    dir.list_dir_begin()
    var cur_file = dir.get_next()
    var z_indices := [3, 0, 2, 1]
    var z_ind := 0
    var dic_layers := {}
    var layers := [[], [], [], []]
    while cur_file:
        if cur_file.get_extension() == "png":
            var path : String = "%s/%s" % [dir.get_current_dir(), cur_file]
            dir.get_current_dir()
            var tex = ResourceLoader.load(path)
            var key_name: String = cur_file.get_basename().split("_")[0].capitalize()
            if not dic_layers.has(key_name):
                dic_layers[key_name] = [[], z_indices[z_ind]]
                z_ind += 1
            dic_layers[key_name][0].append(tex.get_image())
        cur_file = dir.get_next()
    dir.list_dir_end()
    for key in dic_layers.keys():
        layers[dic_layers[key][1]] = [key, dic_layers[key][0]]
    sprite["layers"] = layers
    # Preview
    const colors = [
        Color("000000ff"), # 0
        Color("9c6259ff"), # 1
        Color("d78c81ff"), # 2
        Color("191919ff"), # 3
        Color("000000ff"), # 4
        Color("585858ff"), # 5
        Color("3a3a3aff"), # 6
        Color("909090ff"), # 7
        Color("000000ff"), # 8
        Color("443e3eff"), # 9
        Color("342f2fff"), # 10
        Color("232323ff"), # 11
        Color("232323ff"), # 12
        Color("353535ff"), # 13
        Color("6a6a6aff"), # 14
        Color("5f5f5fff"), # 15
        Color("949494ff"), # 16
        Color("007b68ff"), # 17
        Color("ba0016ff"), # 18
    ]
    # Preview images
    var preview_images := [0, 0, 0, 0]
    for i in layers.size():
        var img: Image = layers[i][1][1 if i == 2 else 0].duplicate()
        img.crop(24, 24)
        preview_images[i] = img
    # blend preview images
    var preview: Image = preview_images.pop_front()
    for img in preview_images:
        preview.blend_rect(img, Rect2i(Vector2i.ZERO, Vector2i(24, 24)), Vector2i.ZERO)
    # replace preview colors
    for x in range(preview.get_size().x):
        for y in range(preview.get_size().y):
            if preview.get_pixel(x, y).a == 0.0:
                continue
            var cur_col := preview.get_pixel(x, y)
            if Global.SHADER_COLORS.has(cur_col):
                var col = colors[Global.SHADER_COLORS.find(cur_col)]
                preview.set_pixel(x, y, col)
    sprite["preview"] = preview
    # Return default character dictionary
    return sprite


static func get_saved_sprites() -> Dictionary:
    var dir := DirAccess.open(get_sprites_path())
    dir.list_dir_begin()
    var cur_file := dir.get_next()
    var sprites := {}
    while cur_file:
        if cur_file.get_extension() == "pds":
            var file := FileAccess.open("%s/%s" % [dir.get_current_dir(), cur_file], FileAccess.READ)
            var spr = file.get_var(true)
            file.close()
            sprites[cur_file.get_basename()] = spr
        cur_file = dir.get_next()
    return sprites
