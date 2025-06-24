class_name Ball extends RigidBody3D

const SPAWN_HEIGHT = 1.5
const SPAWN_OFFSET = .5

var is_physics_authority: bool = false

func _ready() -> void:
	freeze = not is_physics_authority
	freeze_mode = FREEZE_MODE_KINEMATIC

func launch(source: Node3D) -> void:
	var forward: Vector3 = source.global_transform.basis.z
	global_transform.origin = source.global_transform.origin + forward * SPAWN_OFFSET + Vector3.UP * SPAWN_HEIGHT

	var speed = 20.0
	linear_velocity = forward * speed
