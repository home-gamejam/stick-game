extends CharacterBody3D

class_name Character

const MOVE_SPEED = 5.0

@export var acceleration: float = 20.0
@export var air_deceleration: float = 3
@export var rotation_speed = TAU * 2
@export var max_floor_distance: float = .2

@onready var character_model = %Model as CharacterModel
@onready var character_view = %View as CharacterView
@onready var foot_collider_l = %FootColliderL as CollisionShape3D
@onready var foot_collider_r = %FootColliderR as CollisionShape3D

var move_speed = MOVE_SPEED
var last_input_dir := Vector2.ZERO
var last_rot_input_dir := Vector2.ZERO
var last_move_dir := Vector3.BACK
var last_rotation_dir := Vector3.BACK

func _physics_process(delta: float) -> void:
	# If this is not the authority, we don't process physics. The multiplayer
	# synchronizer will handle the movement and state updates.
	if not is_multiplayer_authority():
		return

	character_model.update(get_input(), delta)

# Override this for specific character types. E.g. player will use input from
# user inputs. Npcs will use AI inputs.
func get_input() -> InputData:
	return InputData.new()

func get_forward_axis() -> Vector3:
	return -global_basis.z

func get_right_axis() -> Vector3:
	return -global_basis.x

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

	character_model.global_rotation.y = lerp_angle(character_model.rotation.y, target_angle, rotation_speed * delta)
	character_view.global_rotation.y = character_model.global_rotation.y
