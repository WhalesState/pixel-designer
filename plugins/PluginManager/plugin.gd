extends Plugin

var plugin_manager: PluginManager


func load_plugin() -> void:
	plugin_manager = PluginManager.new()
	add_control_to_settings(plugin_manager, "Plugin", get_plugin_info())


func unload_plugin() -> void:
	remove_control_from_settings(plugin_manager)
	plugin_manager.free()


func get_plugin_info() -> String:
	return "Enable/Disable Plugins"


func get_plugin_version() -> String:
	return "0.0.1"


func is_internal() -> bool:
	return true
