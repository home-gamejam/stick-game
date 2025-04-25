#@tool
extends Character

@export_range(0.0, 1.0) var mouse_sensitivity = 0.01
@export var tilt_limit = deg_to_rad(75)
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

func get_direction(input_dir: Vector2) -> Vector3:
	var camera: Camera3D = _player_camera.camera
	var forward := camera.global_basis.z
	var right := camera.global_basis.x

	var direction := forward * input_dir.y + right * input_dir.x

	return direction.normalized()

func get_model() -> Node3D:
	return %Model

func set_animation_blend_position(blend_position: int) -> void:
	_animation_tree.set("parameters/Movement/blend_position", blend_position)
