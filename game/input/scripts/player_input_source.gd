extends InputSource

class_name PlayerInputSource

func get_input() -> InputData:
	var input_data = InputData.new()

	if Input.is_action_just_pressed("jump"):
		input_data._actions.append("jump")

	if Input.is_action_just_pressed("punch"):
		input_data._actions.append("punch")

	if Input.is_action_pressed("run"):
		input_data._actions.append("run")

	input_data.input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down", .1)

	return input_data