extends State

class_name MoveState

@export var idle_state: IdleState
@export var jump_state: JumpState
@export var fall_state: FallState

# func enter() -> void:
# 	character.play_animation("stickman_animations/Walk")

func physics_process(delta: float) -> State:
	if not character.is_on_floor():
		return fall_state

	if Input.is_action_just_pressed("jump"):
		return jump_state

	var is_running = Input.is_action_pressed("run")

	if is_running:
		character.move_speed = character.MOVE_SPEED * 2
	else:
		character.move_speed = character.MOVE_SPEED

	var input_dir = get_input_dir()
	character.move_based_on_input(delta, input_dir)

	if character.velocity.length() == 0:
		return idle_state

	# blend_position is 0, 1, 2 for idle, walk, run respectively. Multiplying
	# walk or run by the input_dir magnitude should hit the values exactly when
	# value is 1 and a blend when it is < 1
	var blend_position = (2 if is_running else 1) * input_dir.normalized().length()
	print("blend_position: ", blend_position)
	character.set_animation_blend_position(blend_position)

	return null
