extends Plugin


var rect: PanelContainer


func load_plugin():
	rect = PanelContainer.new()
	rect.name = "Test"
	add_control_to_main_screen(rect, "", "Test Plugin")


func unload_plugin():
	remove_control_from_main_screen(rect)
	rect.free()
