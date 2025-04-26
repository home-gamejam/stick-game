extends State

class_name MoveState

@export var idle_state: IdleState
@export var jump_state: JumpState
@export var fall_state: FallState

@export var acceleration: float = 20.0
@export var rotation_speed = TAU * 2

const SPEED = 5.0

var speed = SPEED

# func enter() -> void:
# 	character.play_animation("stickman_animations/Walk")

func physics_process(delta: float) -> State:
	if not character.is_on_floor():
		return fall_state

	if Input.is_action_just_pressed("ui_accept"):
		return jump_state

	var is_running = Input.is_action_pressed("run")

	if is_running:
		speed = SPEED * 2
	else:
		speed = SPEED

	var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction = character.get_direction(input_dir)

	# temporarily zero the y velocity while we call move_toward, then restore it
	var vel_y := character.velocity.y
	character.velocity.y = 0.0
	character.velocity = character.velocity.move_toward(direction * speed, acceleration * delta)
	character.velocity.y = vel_y

	character.move_and_slide()

	if direction.length() > 0.2:
		character.last_direction = direction

	if character.velocity.length() == 0:
		return idle_state

	var target_angle := Vector3.BACK.signed_angle_to(character.last_direction, Vector3.UP)
	character.model.global_rotation.y = lerp_angle(character.model.rotation.y, target_angle, rotation_speed * delta)

	# blend_position is 0, 1, 2 for idle, walk, run respectively. Multiplying
	# walk or run by the input_dir magnitude should hit the values exactly when
	# value is 1 and a blend when it is < 1
	var blend_position = (2 if is_running else 1) * input_dir.normalized().length()
	print("blend_position: ", blend_position)
	character.set_animation_blend_position(blend_position)

	return null
