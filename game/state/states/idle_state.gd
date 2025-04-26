extends State

class_name IdleState

@export var jump_state: JumpState
@export var move_state: MoveState

func enter():
	character.play_animation("stickman_animations/Idle")

func physics_process(_delta: float) -> State:
	if Input.is_action_just_pressed("ui_accept") and character.is_on_floor():
		return jump_state

	var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	if input_dir.length() > 0:
		return move_state

	return null
