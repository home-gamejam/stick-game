extends CharacterState

class_name IdleState

func enter():
	character.play_animation("stickman_animations/Idle")

func physics_process(delta: float) -> CharacterState.Type:
	if character.is_in_air():
		return CharacterState.Type.Fall

	if Input.is_action_just_pressed("jump") and character.is_on_floor():
		return CharacterState.Type.Jump

	if Input.is_action_just_pressed("punch"):
		return CharacterState.Type.Punch1Start

	var input_dir := get_input_dir()
	if input_dir.length() > 0:
		return CharacterState.Type.Move

	character.move_based_on_input(delta)

	return CharacterState.Type.None
