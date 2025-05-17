extends CharacterState

class_name Punch2StartState

var combo_window: int = 0

func enter():
	character.play_animation("stickman_animations/Punch2Start")
	combo_window = 0

func physics_process(_delta: float) -> CharacterState.Type:
	# if Input.is_action_just_pressed("punch"):
	# 	combo_window = 5
	if not character.is_animation_playing():
	# 	if combo_window > 0:
	# 		return punch2_start_state
		return CharacterState.Type.FightIdle

	character.move_and_slide()

	return CharacterState.Type.None