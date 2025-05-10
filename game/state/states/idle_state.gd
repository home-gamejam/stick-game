extends State

class_name IdleState

@export var fall_state: FallState
@export var jump_state: JumpState
@export var move_state: MoveState

func enter():
	character.play_animation("stickman_animations/Idle")

func physics_process(delta: float) -> State:
	if not character.is_on_floor():
		return fall_state

	if Input.is_action_just_pressed("jump") and character.is_on_floor():
		return jump_state

	var input_dir := get_input_dir()
	print("idle_state input_dir: ", input_dir)
	if input_dir.length() > 0:
		return move_state

	character.move_based_on_input(delta)

	return null
