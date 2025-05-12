extends CharacterState

class_name Punch1StartState

var combo_window: int = 0

func enter():
	character.play_animation("stickman_animations/Punch1Start")
	combo_window = 0

func physics_process(_delta: float) -> CharacterState.Type:
	if Input.is_action_just_pressed("punch"):
		combo_window = 10

	if not character.is_animation_playing():
		if combo_window > 0:
			return CharacterState.Type.Punch2Start

		return CharacterState.Type.Punch1End

	if combo_window > 0:
		combo_window -= 1

	return CharacterState.Type.None