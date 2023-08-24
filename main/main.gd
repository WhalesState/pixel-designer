@tool
extends MarginContainer

const GLOBAL = preload("./global.gd")
const CLASS = preload("./classes.gd")


func _init():
	if GLOBAL.is_first_run():
		var err = GLOBAL.save_sprite(GLOBAL.get_default_character())
		print_debug("Save Default Character sprite: %s" % err == OK)


func _ready():
	get_tree().get_root().min_size = Vector2i(1024, 768)
	$"%VersionButton".text = "Pixel Designer v%s" % GLOBAL.VERSION
	# load sprites
	var sprites = GLOBAL.get_saved_sprites()
	for spr in sprites.values():
		var new_spr = CLASS.SpriteButton.new(spr, GLOBAL.SPRITES_GROUP)
		new_spr.edit_sprite.connect(_on_edit_sprite)
		get_node("%SpritesFlow").add_child(new_spr)
	get_node("%SpritesFlow").get_child(0).button_pressed = true


func _on_edit_sprite(spr: Dictionary):
	print(spr["name"])
