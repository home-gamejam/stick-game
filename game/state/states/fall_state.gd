extends State

class_name FallState

@export var idle_state: IdleState

func physics_process(delta: float) -> State:
	character.velocity += character.get_gravity() * delta

	character.move_and_slide()

	if character.is_on_floor():
		return idle_state

	return null