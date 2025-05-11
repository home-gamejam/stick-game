extends State

class_name FightIdleState

@export var idle_state: IdleState

const DURATION = 5.0

var timer: float

func enter():
	character.play_animation("stickman_animations/FightIdle")
	timer = 0.0

func physics_process(delta: float) -> State:
	timer += delta
	if timer > DURATION:
		return idle_state

	return null