class_name Ball extends RigidBody3D

const SPAWN_HEIGHT = 1.5
const SPAWN_OFFSET = .5
const SPEED = 20.0

var is_physics_authority: bool = false

# Peer id is key in order for multiplayer synchronization to work correctly.
# We store it in the name so that it is available when the spawner creates the
# scene. Then we parse the pid out in the getter when the scene enters the tree.
var pid: int:
	set(value):
		# When this scene is added to a parent with `force_readable_name` set to
		# true, an auto-incrementing name is generated. Using the `_` suffix so
		# we can easily parse the pid and ignore any auto-added numeric suffixes.
		name = str(value) + "_"
	get:
		return name.split("_")[0].to_int()

# var _target_position: Vector3
# @export var target_position: Vector3:
# 	get:
# 		return _target_position
# 	set(value):
# 		_target_position = value
@export var target_position: Vector3

func _enter_tree():
	freeze = not is_physics_authority
	freeze_mode = FREEZE_MODE_KINEMATIC
	set_multiplayer_authority(pid)

func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	if not is_physics_authority:
		state.transform.origin = target_position

func _physics_process(_delta: float) -> void:
	if is_physics_authority:
		target_position = transform.origin

func launch(source: Node3D) -> void:
	var forward: Vector3 = source.global_transform.basis.z
	global_transform.origin = source.global_transform.origin + forward * SPAWN_OFFSET + Vector3.UP * SPAWN_HEIGHT

	linear_velocity = forward * SPEED
