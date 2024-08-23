@tool
class_name SvgImage
extends SvgNode

@export var position := Vector2.ZERO:
	set(value):
		if value != position:
			position = value
			update()

@export_global_file("*.png") var image_path: String:
	set(value):
		image_path = value
		update()


func get_svg_string():
	if FileAccess.file_exists(image_path):
		var img := Image.load_from_file(image_path)
		if not img:
			return
		var size = img.get_size()
		img = null
		var s = '<image x="%s" y="%s" width="%s" height="%s" href="%s"' % [position.x, position.y, size.x, size.y, image_path]
		if not mask_id.is_empty():
			s += ' mask="url(#%s)"' % mask_id
		s += '/>'
		return s
	return ""
