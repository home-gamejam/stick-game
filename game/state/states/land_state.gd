extends State

class_name LandState

@export var idle_state: IdleState

func enter() -> void:
	character.play_animation("stickman_animations/Land")

func physics_process(delta: float) -> State:
	character.velocity += character.get_gravity() * delta

	character.move_and_slide()

	if character.is_on_floor():
		return idle_state

	return null