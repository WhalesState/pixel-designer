@tool
class_name CheckerButton
extends Button

## checker modulate color.
@export var checker_modulate := Color(1.0, 1.0, 1.0, 0.5):
    set(value):
        checker_modulate = value
        checker.modulate = checker_modulate

## checker.
var checker := Checker.new(Vector2i(8, 8), Vector2i(1, 1))


func _init():
    theme_type_variation = "CheckerButton"
    # Checker
    checker.modulate = checker_modulate
    checker.set_anchors_and_offsets_preset(PRESET_FULL_RECT)
    add_child(checker, true, INTERNAL_MODE_FRONT)
