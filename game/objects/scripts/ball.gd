class_name Ball extends RigidBody3D

const SPAWN_HEIGHT = 1.5
const SPAWN_OFFSET = .5
const SPEED = 20.0

var pid: int
var is_physics_authority: bool = false

@export var target_position: Vector3

func init(pid_: int) -> Ball:
	pid = pid_
	return self

func _enter_tree():
	set_multiplayer_authority(pid)
	is_physics_authority = is_multiplayer_authority()
	freeze = not is_physics_authority
	freeze_mode = FREEZE_MODE_KINEMATIC

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
