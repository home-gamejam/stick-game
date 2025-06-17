class_name InputData

var _actions: Array[String] = []

# Return the first action in the actions array, or an empty string if there are
# no actions
var action: String:
	get:
		return _actions[0] if _actions.size() > 0 else ""

var input_dir: Vector2 = Vector2.ZERO
