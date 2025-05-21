extends CharacterState

class_name Punch1EndState

func _init(character_: Character) -> void:
	animation = "stickman_animations/Punch1End"
	character = character_

func physics_process(delta: float) -> CharacterState.Type:
	if not character.is_animation_playing():
		return CharacterState.Type.FightIdle

	character.move_based_on_input(delta, Vector2.ZERO)

	return CharacterState.Type.None