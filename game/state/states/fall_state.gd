extends State

class_name FallState

@export var land_state: LandState

func enter() -> void:
	character.play_animation("stickman_animations/Fall")

func physics_process(delta: float) -> State:
	character.velocity += character.get_gravity() * delta

	character.move_and_slide()

	if character.is_on_floor():
		return land_state

	return null