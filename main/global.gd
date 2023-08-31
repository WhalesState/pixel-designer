extends Object

const VERSION := "1.1.alpha"

const SPRITES_GROUP: ButtonGroup = preload("./groups/sprites_group.tres")


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
    var spr_name: String = sprite["name"]
    spr_name = spr_name.replace(" ", "_")
    if not spr_name.is_valid_filename():
        print_debug("ERROR: Invalid Sprite Name!")
        return ERR_INVALID_PARAMETER
    var file := FileAccess.open("%s/%s.pds" % [path, spr_name], FileAccess.WRITE)
    file.store_var(sprite, true)
    file.close()
    return OK


static func create_new_sprite(spr_name: String, spr_size: Vector2i) -> int:
    var img := Image.create(spr_size.x, spr_size.y, false, Image.FORMAT_RGBA8)
    var sprite := {
        "name": spr_name,
        "size": spr_size,
        "animations": {"default": [[0], false]},
        "material_ids": {"const": [0, 1]},
        "materials": {"const": [["000000ff", "ffffffff"]]},
        "layers": [["default", [img]]],
        "preview": img.duplicate(),
    }
    return save_sprite(sprite)


static func get_default_character() -> Dictionary:
    var images_path := "res://main/default_character/"
    # Sprite defaults
    var sprite := {
        "name": "Default Character",
        "size": Vector2i(24, 24),
        "animations": {},
        "material_ids": {},
        "materials": {},
        "layers": [],
        "preview": null,
    }
    # Animations
    var animations := {}
    animations["default"] = [[0], false]
    animations["idle"] = [[0, 2, 1, 2], true]
    animations["run"] = [[3, 4, 5, 6, 7], true]
    animations["jump"] = [[8, 9, 10, 11], true]
    animations["die"] = [[2, 12, 13], false]
    sprite["animations"] = animations
    # Material ids
    const material_ids = {
        "const": [0, 1],
        "skin": [2, 3],
        "eyes": [4],
        "cloth": [5, 6, 7],
        "hair": [8, 9, 10],
        "item": [11, 12, 13],
        "metal": [14, 15],
        "mask": [16, 17]
    }
    sprite["material_ids"] = material_ids
    # Materials
    const materials = {
        "const": [["000000ff", "ffffffff"]],
        "skin": [
            ["9c6259ff", "d78c81ff"],
            ["61372fff", "8a433bff"],
            ["3d211dff", "54332fff"]
        ],
        "eyes": [["191919ff"], ["203220ff"], ["003f9dff"]],
        "cloth": [
            ["3a3a3aff", "585858ff", "909090ff"],
            ["44252fff", "4f3243ff", "a06078ff"],
            ["8f4029ff", "c35143ff", "d79053ff"]
        ],
        "hair": [
            ["232323ff", "342f2fff", "443e3eff"],
            ["2a2524ff", "504b4cff", "6a6465ff"],
            ["712f0eff", "a34617ff", "c6721eff"]
        ],
        "item": [
            ["232323ff", "353535ff", "6a6a6aff"],
            ["491324ff", "5e2840ff", "94617eff"],
            ["4c130bff", "692121ff", "8a2f2fff"]
        ],
        "metal": [["5f5f5fff", "949494ff"]],
        "mask": [["007b68ff", "ba0016ff"]]
    }
    sprite["materials"] = materials
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
            var key_name: String = cur_file.get_basename().split("_")[0]
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
        Color("ffffffff"), # 1
        Color("9c6259ff"), # 2
        Color("d78c81ff"), # 3
        Color("191919ff"), # 4
        Color("3a3a3aff"), # 5
        Color("585858ff"), # 6
        Color("909090ff"), # 7
        Color("232323ff"), # 8
        Color("342f2fff"), # 9
        Color("443e3eff"), # 10
        Color("232323ff"), # 11
        Color("353535ff"), # 12
        Color("6a6a6aff"), # 13
        Color("5f5f5fff"), # 14
        Color("949494ff"), # 15
        Color("007b68ff"), # 16
        Color("ba0016ff"), # 17
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
            if Constants.SHADER_COLORS.has(cur_col):
                var col = colors[Constants.SHADER_COLORS.find(cur_col)]
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
