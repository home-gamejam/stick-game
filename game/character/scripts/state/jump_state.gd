extends CharacterState

class_name JumpState

const JUMP_VELOCITY = 4.5 * 1.2

func _init(character_model_: CharacterModel) -> void:
	animation = "Jump"
	character_model = character_model_

func enter() -> void:
	character_model.velocity.y = JUMP_VELOCITY

func update(input_data: InputData, delta: float) -> CharacterState.Type:
	character_model.velocity += character_model.get_gravity() * delta

	if character_model.velocity.y > 0:
		return CharacterState.Type.Fall

	character_model.move_based_on_input(
		delta,
		input_data.input_dir * .1,
		character_model.last_input_dir)

	if character_model.is_on_floor():
		return CharacterState.Type.Idle

	return CharacterState.Type.None