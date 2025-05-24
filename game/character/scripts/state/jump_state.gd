extends CharacterState

class_name JumpState

const JUMP_VELOCITY = 4.5 * 1.2

func _init(character_model_: CharacterModel) -> void:
	animation = "stickman_animations/Jump"
	character_model = character_model_

func enter() -> void:
	character_body.velocity.y = JUMP_VELOCITY

func update(input_data: InputData, delta: float) -> CharacterState.Type:
	character_body.velocity += character_body.get_gravity() * delta

	if character_body.velocity.y > 0:
		return CharacterState.Type.Fall

	character_body.move_based_on_input(
		delta,
		input_data.input_dir * .1,
		character_body.last_input_dir)

	if character_body.is_on_floor():
		return CharacterState.Type.Idle

	return CharacterState.Type.None