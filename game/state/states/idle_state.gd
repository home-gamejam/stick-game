extends State

class_name IdleState

@export var jump_state: JumpState
@export var move_state: MoveState

func enter():
	var blend_position := 0
	character._animation_tree.set("parameters/Movement/blend_position", blend_position)

func physics_process(_delta: float) -> State:
	if Input.is_action_just_pressed("ui_accept") and character.is_on_floor():
		return jump_state

	var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	if input_dir.length() > 0:
		return move_state

	return null
