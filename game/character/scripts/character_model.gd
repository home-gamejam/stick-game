extends CharacterBody3D

class_name CharacterModel

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

@onready var animation_player = %AnimationPlayer as AnimationPlayer
@onready var animation_tree = %AnimationTree as AnimationTree
@onready var states: Dictionary[CharacterState.Type, CharacterState] = {
	CharacterState.Type.Fall: FallState.new(self),
	CharacterState.Type.FightIdle: FightIdleState.new(self),
	CharacterState.Type.Idle: IdleState.new(self),
	CharacterState.Type.Jump: JumpState.new(self),
	CharacterState.Type.Land: LandState.new(self),
	CharacterState.Type.Move: MoveState.new(self),
	CharacterState.Type.Punch1Start: Punch1StartState.new(self),
	CharacterState.Type.Punch1End: Punch1EndState.new(self),
	CharacterState.Type.Punch2Start: Punch2StartState.new(self),
}

var move_speed = walk_speed
var last_input_dir := Vector2.ZERO
var last_rot_input_dir := Vector2.ZERO
var last_move_dir := Vector3.BACK
var last_rotation_dir := Vector3.BACK

var adjusted_basis: Basis

var current_state_type: CharacterState.Type = CharacterState.Type.Idle:
	set(current_state_type_):
		if current_state_type_ == current_state_type:
			return

		current_state_type = current_state_type_

		# playing animation in the setter since multiplayer synchronizer sets
		# the state type without going through the state lifecylce managed by
		# _transition_state
		play_animation(current_state.animation)

var current_state: CharacterState:
	get:
		return states[current_state_type]

func _ready() -> void:
	_transition_state(current_state_type)

func _transition_state(new_state_type: CharacterState.Type) -> void:
	# Only update if we have a new state
	if new_state_type == CharacterState.Type.None:
		return

	current_state.exit()
	current_state_type = new_state_type
	current_state.enter()

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

func get_animation_length(animation: String) -> float:
	return animation_player.get_animation(animation).length

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

	var move_direction := get_forward_axis() * input_dir.y + get_right_axis() * input_dir.x
	move_direction = move_direction.normalized()

	var rotation_direction := move_direction
	if input_dir != rot_input_dir:
		rotation_direction = get_forward_axis() * rot_input_dir.y + get_right_axis() * rot_input_dir.x
		rotation_direction = rotation_direction.normalized()

	var rate = acceleration if is_on_floor() else air_deceleration
	# temporarily zero the y velocity while we call move_toward, then restore it
	var vel_y := velocity.y
	velocity.y = 0.0
	velocity = velocity.move_toward(move_direction * move_speed, rate * delta)
	velocity.y = vel_y

	move_and_slide()

	if move_direction.length() > 0.2:
		last_move_dir = move_direction

	if rotation_direction.length() > 0.2:
		last_rotation_dir = rotation_direction

	var target_angle := Vector3.BACK.signed_angle_to(last_rotation_dir, Vector3.UP)

	rig.global_rotation.y = lerp_angle(rig.rotation.y, target_angle, rotation_speed * delta)

func play_animation(animation: String) -> void:
	match animation:
		"Idle", "Walk", "Run":
			animation_tree.active = true
			animation_tree.set("parameters/Movement/blend_position", 0)

		_:
			animation_tree.active = false
			animation_player.play(animation)

func set_animation_blend_position(blend_position: Variant) -> void:
	animation_tree.set("parameters/Movement/blend_position", blend_position)

# Update the character state based on input data and delta time
func update(input_data: InputData, delta: float) -> void:
	var new_state_type = current_state.update(input_data, delta)
	_transition_state(new_state_type)
