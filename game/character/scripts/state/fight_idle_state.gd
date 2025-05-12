extends IdleState

class_name FightIdleState

const DURATION = 5.0

var timer: float

func enter():
	character.play_animation("stickman_animations/FightIdle")
	timer = 0.0

func physics_process(delta: float) -> CharacterState.Type:
	timer += delta
	if timer > DURATION:
		return CharacterState.Type.Idle

	return super.physics_process(delta)