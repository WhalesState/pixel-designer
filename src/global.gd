extends Node

var undo_redo = UndoRedo.new()

# enum {
#     ACTION,
#     UNDO_FUNCTION,
#     REDO_FUNCTION,
# }

# var history := []
# var cur_action := -1
# var action := ""
# var undo_func = null
# var redo_func = null


# func _ready():
#     print("UndoRedoManager ready")


# func commit_action():
#     if history.size() > cur_action + 1:
#         history.resize(cur_action + 1)
#     history.append([action, undo_func, redo_func])
#     cur_action = history.size() - 1
#     action = ""
#     undo_func = null
#     redo_func = null
#     prints(cur_action, history.size())


# func undo():
#     if cur_action >= 0:
#         var callable: Callable = history[cur_action][UNDO_FUNCTION]
#         callable.call()
#         cur_action -= 1
#     prints(cur_action, history.size())


# func redo():
#     print("Redo")
