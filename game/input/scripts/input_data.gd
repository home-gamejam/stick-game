class_name InputData

enum Action {
	None = 0,
	Jump,
	Punch,
	Run
}

var _actions: Array[Action] = []

# Return the first action in the actions array, or an empty string if there are
# no actions
var action: Action:
	get:
		return _actions[0] if _actions.size() > 0 else Action.None

var input_dir: Vector2 = Vector2.ZERO
