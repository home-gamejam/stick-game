extends CharacterState

class_name Punch2StartState

var combo_window: int = 0

func _init(character_model_: CharacterModel) -> void:
	animation = "stickman_animations/Punch2Start"
	character_model = character_model_

func enter():
	combo_window = 0

func update(_input_data: InputData, delta: float) -> CharacterState.Type:
	# if Input.is_action_just_pressed("punch"):
	# 	combo_window = 5
	if not character_model.is_animation_playing():
	# 	if combo_window > 0:
	# 		return punch2_start_state
		return CharacterState.Type.FightIdle

	character_body.move_based_on_input(delta, Vector2.ZERO)

	return CharacterState.Type.None