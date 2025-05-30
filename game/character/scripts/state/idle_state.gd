extends CharacterState

class_name IdleState

func _init(character_model_: CharacterModel) -> void:
	animation = "Idle"
	character_model = character_model_

func update(input_data: InputData, delta: float) -> CharacterState.Type:
	if character_model.is_in_air():
		return CharacterState.Type.Fall

	if input_data.action == "jump" and character_model.is_on_floor():
		return CharacterState.Type.Jump

	if input_data.action == "punch":
		return CharacterState.Type.Punch1Start

	if input_data.input_dir.length() > 0:
		return CharacterState.Type.Move

	character_model.move_based_on_input(delta)

	return CharacterState.Type.None
