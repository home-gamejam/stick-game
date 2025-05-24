extends CharacterState

class_name LandState

func _init(character_model_: CharacterModel) -> void:
	animation = "stickman_animations/Land"
	character_model = character_model_

func update(_input_data: InputData, delta: float) -> CharacterState.Type:
	character_body.velocity += character_body.get_gravity() * delta

	character_body.move_based_on_input(delta)

	if character_body.is_on_floor():
		return CharacterState.Type.Idle

	return CharacterState.Type.None