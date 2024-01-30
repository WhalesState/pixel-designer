@tool
extends Tree

var sprite_vp: SubViewport:
	set(value):
		if not value is SubViewport:
			sprite_vp = null
			clear()
			return
		sprite_vp = value
		reload_layers()


func reload_layers():
	clear()
	if not sprite_vp:
		return
	var root := create_item()
	root.set_meta("node", sprite_vp)
	root.set_text(0, sprite_vp.name)