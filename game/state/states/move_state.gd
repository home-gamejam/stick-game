extends State

class_name MoveState

func enter() -> void:
	character.play_animation("stickman_animations/Walk")

func physics_process(delta: float) -> CharacterState.Type:
	if not character.is_on_floor():
		return CharacterState.Type.Fall

	if Input.is_action_just_pressed("jump"):
		return CharacterState.Type.Jump

	if Input.is_action_just_pressed("punch"):
		return CharacterState.Type.Punch1Start

	var is_running = Input.is_action_pressed("run")

	if is_running:
		character.move_speed = character.MOVE_SPEED * 2
	else:
		character.move_speed = character.MOVE_SPEED

	var input_dir = get_input_dir()
	character.move_based_on_input(delta, input_dir)

	if character.velocity.length() == 0:
		return CharacterState.Type.Idle

	# blend_position is 0, 1, 2 for idle, walk, run respectively. Multiplying
	# walk or run by the input_dir magnitude should hit the values exactly when
	# value is 1 and a blend when it is < 1
	var blend_position = (2 if is_running else 1) * input_dir.normalized().length()
	print("blend_position: ", blend_position)
	character.set_animation_blend_position(blend_position)

	return CharacterState.Type.None
