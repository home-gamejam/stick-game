class_name CharacterModel extends CharacterBody3D

enum CharacterStateType {
	None = 0,
	Idle,
	Fall,
	FightIdle,
	Jump,
	Land,
	Move,
	Punch1Start,
	Punch1End,
	Punch2Start,
}

@export var acceleration: float = 20.0
@export var air_deceleration: float = 3
@export var rotation_speed = TAU * 2
@export var max_floor_distance: float = .2
@export var walk_speed: float = 5.0

@onready var hand_collider_l = %HandColliderL as CollisionShape3D
@onready var hand_collider_r = %HandColliderR as CollisionShape3D
@onready var foot_collider_l = %FootColliderL as CollisionShape3D
@onready var foot_collider_r = %FootColliderR as CollisionShape3D
@onready var rig = %rig as Node3D
@onready var hit_skeleton_modifier = %HitSkeletonModifier as HitSkeletonModifier

@onready var animation_player = %AnimationPlayer as AnimationPlayer
@onready var animation_tree = %AnimationTree as AnimationTree

var move_speed = walk_speed
var last_input_dir := Vector2.ZERO
var last_rot_input_dir := Vector2.ZERO
var last_move_dir := Vector3.BACK
var last_rotation_dir := Vector3.BACK

var adjusted_basis: Basis:
	get:
		return adjusted_basis if adjusted_basis else global_basis.inverse()
	set(value):
		adjusted_basis = value

var adjusted_rotation: float:
	get:
		return adjusted_rotation if adjusted_rotation else 0.0
	set(value):
		adjusted_rotation = value

var is_transition: bool = false
var state_type: CharacterStateType = CharacterStateType.Idle:
	set(state_type_):
		if state_type_ == state_type:
			return

		state_type = state_type_

		# playing animation in the setter since multiplayer synchronizer sets
		# the state type without going through the state lifecylce managed by
		play_animation()

func update(input: InputData, delta: float) -> void:
	var prev_state_type: CharacterStateType = state_type

	match state_type:
		CharacterStateType.Idle:
			_update_idle(input, delta)
		CharacterStateType.Fall:
			_update_fall(input, delta)
		CharacterStateType.FightIdle:
			_update_fight_idle(input, delta)
		CharacterStateType.Jump:
			_update_jump(input, delta)
		CharacterStateType.Land:
			_update_land(input, delta)
		CharacterStateType.Move:
			_update_move(input, delta)
		CharacterStateType.Punch1Start:
			_update_punch1_start(input, delta)
		CharacterStateType.Punch1End:
			_update_punch1_end(input, delta)
		CharacterStateType.Punch2Start:
			_update_punch2_start(input, delta)

	is_transition = state_type != prev_state_type
	if is_transition:
		print("transition", state_type)

func _update_idle(input: InputData, delta: float) -> void:
	if is_in_air():
		state_type = CharacterStateType.Fall
		return

	if input.action == InputData.Action.Jump and is_on_floor():
		state_type = CharacterStateType.Jump
		return

	if input.action == InputData.Action.Punch:
		state_type = CharacterStateType.Punch1Start
		return

	if input.input_dir.length() > 0:
		state_type = CharacterStateType.Move
		return

	move_based_on_input(delta)

func _update_fall(input: InputData, delta: float) -> void:
	velocity += get_gravity() * delta

	move_based_on_input(
		delta,
		input.input_dir * .1,
		last_input_dir)

	if is_on_floor():
		state_type = CharacterStateType.Land

const FIGHT_IDLE_DURATION = 5.0
var fight_idle_timer: float
func _update_fight_idle(input: InputData, delta: float) -> void:
	if is_transition:
		fight_idle_timer = 0.0

	fight_idle_timer += delta
	if fight_idle_timer > FIGHT_IDLE_DURATION:
		state_type = CharacterStateType.Idle
		return

	_update_idle(input, delta)

const JUMP_VELOCITY = 4.5 * 1.2
func _update_jump(input: InputData, delta: float) -> void:
	if is_transition:
		velocity.y = JUMP_VELOCITY

	velocity += get_gravity() * delta

	if velocity.y > 0:
		state_type = CharacterStateType.Fall
		return

	move_based_on_input(
		delta,
		input.input_dir * .1,
		last_input_dir)

	if is_on_floor():
		state_type = CharacterStateType.Idle
		return

func _update_land(_input: InputData, delta: float) -> void:
	velocity += get_gravity() * delta

	move_based_on_input(delta)

	if is_on_floor():
		state_type = CharacterStateType.Idle

func _update_move(input_data: InputData, delta: float) -> void:
	if is_in_air():
		state_type = CharacterStateType.Fall
		return

	if input_data.action == InputData.Action.Jump:
		state_type = CharacterStateType.Jump
		return

	if input_data.action == InputData.Action.Punch:
		state_type = CharacterStateType.Punch1Start
		return

	var is_running = input_data.action == InputData.Action.Run

	if is_running:
		move_speed = walk_speed * 2
	else:
		move_speed = walk_speed

	move_based_on_input(delta, input_data.input_dir)

	if velocity.length() == 0:
		state_type = CharacterStateType.Idle
		return

	# blend_position is 0, 1, 2 for idle, walk, run respectively. Multiplying
	# walk or run by the input_dir magnitude should hit the values exactly when
	# value is 1 and a blend when it is < 1
	var blend_position = (2 if is_running else 1) * input_data.input_dir.normalized().length()
	set_animation_blend_position(blend_position)

var animation_length: float
var combo_timer: float = 0.0
var max_combo: float
var min_combo: float
func _update_punch1_start(input: InputData, delta: float) -> void:
	if is_transition:
		animation_length = get_animation_length("Punch1Start")
		min_combo = animation_length - 0.1
		max_combo = animation_length + 0.1
		combo_timer = 0.0

	if input.action == InputData.Action.Punch and combo_timer >= min_combo and combo_timer <= max_combo:
		state_type = CharacterStateType.Punch2Start
		return

	if not is_animation_playing() and combo_timer > max_combo:
		state_type = CharacterStateType.Punch1End
		return

	combo_timer += delta

	move_based_on_input(delta, Vector2.ZERO)

func _update_punch1_end(_input: InputData, delta: float) -> void:
	if not is_animation_playing():
		state_type = CharacterStateType.FightIdle
		return

	move_based_on_input(delta, Vector2.ZERO)

var combo_window: int = 0
func _update_punch2_start(_input: InputData, delta: float) -> void:
	if is_transition:
		combo_window = 0

	# if Input.is_action_just_pressed("punch"):
	# 	combo_window = 5
	if not is_animation_playing():
	# 	if combo_window > 0:
	# 		return punch2_start_state
		state_type = CharacterStateType.FightIdle
		return

	move_based_on_input(delta, Vector2.ZERO)

# is_on_floor() has some issues with the foot colliders where it thinks we are
# in the air sometimes while colliding against walls. This method uses ray
# casting to check a threshold to consider the player in the air.
func is_in_air() -> bool:
	# I'm assuming this is a bit cheaper than checking raycasts on both feet, so
	# bail early if CharacterBody3D says we're on the floor
	if is_on_floor():
		return false

	var space_state := get_world_3d().direct_space_state

	var left_foot_pos: Vector3 = foot_collider_l.global_position
	var right_foot_pos: Vector3 = foot_collider_r.global_position

	for origin_: Vector3 in [left_foot_pos, right_foot_pos]:
		var end := origin_ + Vector3(0, -max_floor_distance, 0)
		var query := PhysicsRayQueryParameters3D.create(origin_, end)
		query.exclude = [self]
		query.collision_mask = 1 # Adjust to floor's layer

		# At least one of the feet is within the max floor distance, so we're
		# not in the air
		var result := space_state.intersect_ray(query)
		if result:
			return false

	return true

func get_adjusted_move_direction(input_dir: Vector2) -> Vector3:
	return Vector3(
		input_dir.x * cos(adjusted_rotation) + input_dir.y * sin(adjusted_rotation),
		0,
		- input_dir.x * sin(adjusted_rotation) + input_dir.y * cos(adjusted_rotation)
	).normalized()

func get_animation_length(animation_: String) -> float:
	return animation_player.get_animation(animation_).length

func get_forward_axis() -> Vector3:
	if adjusted_basis:
		return adjusted_basis.z

	return -global_basis.z

func get_right_axis() -> Vector3:
	if adjusted_basis:
		return adjusted_basis.x

	return -global_basis.x

func get_skeleton_path() -> NodePath:
	return $rig/Skeleton3D.get_path()

func is_animation_playing() -> bool:
	return animation_player.is_playing()

func move_based_on_input(delta: float, input_dir: Vector2 = Vector2.ZERO, rot_input_dir: Vector2 = input_dir) -> void:
	last_input_dir = input_dir
	last_rot_input_dir = rot_input_dir

	var move_direction: Vector3 = get_adjusted_move_direction(input_dir)

	var rotation_direction := move_direction
	if input_dir != rot_input_dir:
		rotation_direction = get_adjusted_move_direction(rot_input_dir)

	var rate = acceleration if is_on_floor() else air_deceleration
	# temporarily zero the y velocity while we call move_toward, then restore it
	var vel_y := velocity.y
	velocity.y = 0.0
	velocity = velocity.move_toward(move_direction * move_speed, rate * delta)
	velocity.y = vel_y

	move_and_slide()

	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		if collider.has_method("get_collision_layer"):
			var layer = collider.get_collision_layer()
			if layer & (1 << 3):
				var vel = collision.get_collider_velocity()
				print("ball vel: ", vel)
				hit_skeleton_modifier.trigger("Chest", vel)


	if move_direction.length() > 0.2:
		last_move_dir = move_direction

	if rotation_direction.length() > 0.2:
		last_rotation_dir = rotation_direction

	var target_angle := Vector3.BACK.signed_angle_to(last_rotation_dir, Vector3.UP)

	if angle_difference(rig.rotation.y, target_angle) < 0.01:
		rig.rotation.y = target_angle
	else:
		rig.rotation.y = lerp_angle(rig.rotation.y, target_angle, rotation_speed * delta)

func play_animation() -> void:
	match state_type:
		CharacterStateType.Idle, CharacterStateType.Move:
			animation_tree.active = true
			animation_tree.set("parameters/Movement/blend_position", 0)

		_:
			animation_tree.active = false
			animation_player.play(CharacterStateType.keys()[state_type])

func set_animation_blend_position(blend_position: Variant) -> void:
	animation_tree.set("parameters/Movement/blend_position", blend_position)
