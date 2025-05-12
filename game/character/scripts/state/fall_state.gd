extends CharacterState

class_name FallState

func enter() -> void:
	character.play_animation("stickman_animations/Fall")

func physics_process(delta: float) -> CharacterState.Type:
	character.velocity += character.get_gravity() * delta

	var input_dir = get_input_dir()
	character.move_based_on_input(
		delta,
		input_dir * .1,
		character.last_input_dir)

	if character.is_on_floor():
		return CharacterState.Type.Land

	return CharacterState.Type.None
