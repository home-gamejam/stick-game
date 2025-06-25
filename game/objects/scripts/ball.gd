class_name Ball extends RigidBody3D

const SPAWN_HEIGHT = 1.5
const SPAWN_OFFSET = .5

var is_physics_authority: bool = false

var _target_position: Vector3
@export var target_position: Vector3:
	get:
		return _target_position
	set(value):
		_target_position = value
		print('set target_position: ', value)

func _ready() -> void:
	freeze = not is_physics_authority
	freeze_mode = FREEZE_MODE_KINEMATIC

func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	if not is_physics_authority:
		state.transform.origin = target_position
		# print("Ball position 2: ", target_position)

func _physics_process(_delta: float) -> void:
	if is_physics_authority:
		_target_position = transform.origin

func launch(source: Node3D) -> void:
	var forward: Vector3 = source.global_transform.basis.z
	global_transform.origin = source.global_transform.origin + forward * SPAWN_OFFSET + Vector3.UP * SPAWN_HEIGHT

	var speed = 20.0
	linear_velocity = forward * speed
