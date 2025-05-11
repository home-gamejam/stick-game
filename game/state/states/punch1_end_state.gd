extends State

class_name Punch1EndState

@export var fight_idle_state: FightIdleState

func enter():
	character.play_animation("stickman_animations/Punch1End")

func physics_process(_delta: float) -> State:
	if not character.is_animation_playing():
		return fight_idle_state

	return null