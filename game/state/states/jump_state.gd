extends State

class_name JumpState

@export var idle_state: IdleState
@export var fall_state: FallState

const JUMP_VELOCITY = 4.5

func enter() -> void:
	character.velocity.y = JUMP_VELOCITY

func physics_process(delta: float) -> State:
	character.velocity += character.get_gravity() * delta

	if character.velocity.y > 0:
		return fall_state

	character.move_and_slide()

	if character.is_on_floor():
		return idle_state

	return null