class_name InputData

var action: String:
	get:
		return actions[0] if actions.size() > 0 else ""

var actions: Array[String] = []

var input_dir: Vector2 = Vector2.ZERO
