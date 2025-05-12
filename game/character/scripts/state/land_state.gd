extends CharacterState

class_name LandState

func enter() -> void:
	character.play_animation("stickman_animations/Land")

func physics_process(delta: float) -> CharacterState.Type:
	character.velocity += character.get_gravity() * delta

	character.move_based_on_input(delta)

	if character.is_on_floor():
		return CharacterState.Type.Idle

	return CharacterState.Type.None