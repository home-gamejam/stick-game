extends CharacterState

class_name FallState

func _init(character_model_: CharacterModel) -> void:
	animation = "stickman_animations/Fall"
	character_model = character_model_

func update(input_data: InputData, delta: float) -> CharacterState.Type:
	character_model.velocity += character_model.get_gravity() * delta

	character_model.move_based_on_input(
		delta,
		input_data.input_dir * .1,
		character_model.last_input_dir)

	if character_model.is_on_floor():
		return CharacterState.Type.Land

	return CharacterState.Type.None
