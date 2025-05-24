extends CharacterState

class_name Punch1EndState

func _init(character_model_: CharacterModel) -> void:
	animation = "stickman_animations/Punch1End"
	character_model = character_model_

func update(_input_data: InputData, delta: float) -> CharacterState.Type:
	if not character_model.is_animation_playing():
		return CharacterState.Type.FightIdle

	character_body.move_based_on_input(delta, Vector2.ZERO)

	return CharacterState.Type.None