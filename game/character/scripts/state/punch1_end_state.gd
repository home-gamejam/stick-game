extends CharacterState

class_name Punch1EndState

func enter():
	character.play_animation("stickman_animations/Punch1End")

func physics_process(delta: float) -> CharacterState.Type:
	if not character.is_animation_playing():
		return CharacterState.Type.FightIdle

	character.move_based_on_input(delta, Vector2.ZERO)

	return CharacterState.Type.None