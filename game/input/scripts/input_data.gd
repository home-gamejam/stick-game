class_name InputData

# Get current input data
static func get_current() -> InputData:
	var input_data = InputData.new()

	if Input.is_action_just_pressed("jump"):
		input_data._actions.append("jump")

	if Input.is_action_just_pressed("punch"):
		input_data._actions.append("punch")

	if Input.is_action_pressed("run"):
		input_data._actions.append("run")

	input_data.input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down", .1)

	return input_data

var _actions: Array[String] = []

# Return the first action in the actions array, or an empty string if there are
# no actions
var action: String:
	get:
		return _actions[0] if _actions.size() > 0 else ""

var input_dir: Vector2 = Vector2.ZERO
