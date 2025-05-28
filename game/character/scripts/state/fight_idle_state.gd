extends IdleState

class_name FightIdleState

const DURATION = 5.0

var timer: float

func _init(character_model_: CharacterModel) -> void:
	animation = "FightIdle"
	character_model = character_model_

func enter():
	timer = 0.0

func update(input_data: InputData, delta: float) -> CharacterState.Type:
	timer += delta
	if timer > DURATION:
		return CharacterState.Type.Idle

	return super.update(input_data, delta)