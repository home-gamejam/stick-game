extends CharacterState

class_name Punch1EndState

func enter():
	character.play_animation("stickman_animations/Punch1End")

func physics_process(_delta: float) -> CharacterState.Type:
	if not character.is_animation_playing():
		return CharacterState.Type.FightIdle

	character.move_and_slide()

	return CharacterState.Type.None