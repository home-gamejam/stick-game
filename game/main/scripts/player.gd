#@tool
extends Character

@export_range(0.0, 1.0) var mouse_sensitivity = 0.01
@export var tilt_limit = deg_to_rad(75)
@export var acceleration: float = 20.0
@export var air_deceleration: float = 3
@export var rotation_speed = TAU * 2

@onready var _animation_player = %AnimationPlayer as AnimationPlayer
@onready var _animation_tree = %AnimationTree as AnimationTree
@onready var _state_machine = %StateMachine as StateMachine

const PLAYER_CAMERA = preload("res://main/player_camera.tscn")

var _player_camera: PlayerCamera

func _enter_tree():
	# this assumes that name was set to the pid
	var id = int(str(name))
	set_multiplayer_authority(id)

func _ready():
	if is_multiplayer_authority():
		_player_camera = PLAYER_CAMERA.instantiate()
		add_child(_player_camera)

	_state_machine.init()

func _physics_process(delta: float) -> void:
	#if Engine.is_editor_hint():
		#return
	if !is_multiplayer_authority():
		return

	_state_machine.physics_process(delta)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion && _player_camera:
		_player_camera.rotation.x -= event.relative.y * mouse_sensitivity
		_player_camera.rotation.x = clampf(_player_camera.rotation.x, -tilt_limit, tilt_limit)
		_player_camera.rotation.y += -event.relative.x * mouse_sensitivity

func get_forward_axis() -> Vector3:
	return _player_camera.camera.global_basis.z

func get_right_axis() -> Vector3:
	return _player_camera.camera.global_basis.x

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
	model.global_rotation.y = lerp_angle(model.rotation.y, target_angle, rotation_speed * delta)


func get_model() -> Node3D:
	return %Model

func set_animation_blend_position(blend_position: int) -> void:
	_animation_tree.set("parameters/Movement/blend_position", blend_position)

func play_animation(animation: String) -> void:
	match animation:
		"stickman_animations/Idle", "stickman_animations/Walk", "stickman_animations/Run":
			_animation_tree.active = true
			_animation_tree.set("parameters/Movement/blend_position", 0)

		_:
			_animation_tree.active = false
			_animation_player.play(animation)
