#@tool
extends CharacterBody3D

@export_range(0.0, 1.0) var mouse_sensitivity = 0.01
@export var tilt_limit = deg_to_rad(75)
@export var player_input: PlayerNetInput

@onready var rollback_synchronizer = $RollbackSynchronizer
@onready var _animation_tree = %AnimationTree as AnimationTree
@onready var _model = %Model as Node3D
@onready var _player_camera = %PlayerCamera as PlayerCamera

const PLAYER_CAMERA = preload("res://scenes/player_camera.tscn")
const ACCELERATION = 20.0
const SPEED = 5.0
const JUMP_VELOCITY = 4.5
const ROTATION_SPEED = TAU * 2

var is_running = false
var last_direction := Vector3.BACK
var speed = SPEED

func _enter_tree():
	set_multiplayer_authority(1)
	# this assumes that name was set to the pid
	player_input.set_multiplayer_authority(str(name).to_int())

func _ready():

	# Set owner
	print("peer_id:", str(name).to_int())
	rollback_synchronizer.process_settings()

	if multiplayer.get_unique_id() == name.to_int():
		_player_camera.camera.current = true
	else:
		_player_camera.camera.current = false


func _rollback_tick(delta: float, _tick, _is_fresh) -> void:
	if !is_multiplayer_authority():
		return

	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if player_input.is_jumping and is_on_floor():
		velocity.y = JUMP_VELOCITY

	is_running = player_input.is_running

	if is_running:
		speed = SPEED * 2
	else:
		speed = SPEED

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := player_input.input_dir

	var camera: Camera3D = _player_camera.camera
	var forward := camera.global_basis.z
	var right := camera.global_basis.x

	var direction := forward * input_dir.y + right * input_dir.x
	direction = direction.normalized()

	# temporarily zero the y velocity while we call move_toward, then restore it
	var vel_y := velocity.y
	velocity.y = 0.0
	velocity = velocity.move_toward(direction * speed, ACCELERATION * delta)
	velocity.y = vel_y

	var velocity_old := velocity
	velocity *= NetworkTime.physics_factor

	move_and_slide()

	velocity = velocity_old

	if direction.length() > 0.2:
		last_direction = direction

	var target_angle := Vector3.BACK.signed_angle_to(last_direction, Vector3.UP)
	_model.global_rotation.y = lerp_angle(_model.rotation.y, target_angle, ROTATION_SPEED * delta)

	# blend_position is 0, 1, 2 for idle, walk, run respectively. Multiplying
	# walk or run by the input_dir magnitude should hit the values exactly when
	# value is 1 and a blend when it is < 1
	var blend_position =  (2 if is_running else 1) * input_dir.length()
	_animation_tree.set("parameters/Movement/blend_position", blend_position)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion && _player_camera:
		_player_camera.rotation.x -= event.relative.y * mouse_sensitivity
		_player_camera.rotation.x = clampf(_player_camera.rotation.x, -tilt_limit, tilt_limit)
		_player_camera.rotation.y += -event.relative.x * mouse_sensitivity
