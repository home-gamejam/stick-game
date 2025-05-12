extends CharacterState

class_name JumpState

const JUMP_VELOCITY = 4.5 * 1.2

func enter() -> void:
	character.velocity.y = JUMP_VELOCITY
	character.play_animation("stickman_animations/Jump")

func physics_process(delta: float) -> CharacterState.Type:
	character.velocity += character.get_gravity() * delta

	if character.velocity.y > 0:
		return CharacterState.Type.Fall

	var input_dir = get_input_dir()
	character.move_based_on_input(
		delta,
		input_dir * .1,
		character.last_input_dir)

	if character.is_on_floor():
		return CharacterState.Type.Idle

	return CharacterState.Type.None