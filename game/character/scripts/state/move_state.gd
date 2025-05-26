extends CharacterState

class_name MoveState

func _init(character_model_: CharacterModel) -> void:
	animation = "stickman_animations/Walk"
	character_model = character_model_

func update(input_data: InputData, delta: float) -> CharacterState.Type:
	if character_model.is_in_air():
		return CharacterState.Type.Fall

	if input_data.action == "jump":
		return CharacterState.Type.Jump

	if input_data.action == "punch":
		return CharacterState.Type.Punch1Start

	var is_running = input_data.action == "run"

	if is_running:
		character_model.move_speed = character_model.walk_speed * 2
	else:
		character_model.move_speed = character_model.walk_speed

	character_model.move_based_on_input(delta, input_data.input_dir)

	if character_model.velocity.length() == 0:
		return CharacterState.Type.Idle

	# blend_position is 0, 1, 2 for idle, walk, run respectively. Multiplying
	# walk or run by the input_dir magnitude should hit the values exactly when
	# value is 1 and a blend when it is < 1
	var blend_position = (2 if is_running else 1) * input_data.input_dir.normalized().length()
	character_model.set_animation_blend_position(blend_position)

	return CharacterState.Type.None
