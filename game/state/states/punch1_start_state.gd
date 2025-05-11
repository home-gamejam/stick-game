extends State

class_name Punch1StartState

@export var punch1_end_state: Punch1EndState
@export var punch2_start_state: Punch2StartState

var combo_window: int = 0

func enter():
	character.play_animation("stickman_animations/Punch1Start")
	combo_window = 0

func physics_process(_delta: float) -> State:
	if Input.is_action_just_pressed("punch"):
		combo_window = 10

	if not character.is_animation_playing():
		if combo_window > 0:
			return punch2_start_state

		return punch1_end_state

	if combo_window > 0:
		combo_window -= 1

	return null