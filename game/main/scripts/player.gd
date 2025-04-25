#@tool
extends CharacterBody3D

@export_range(0.0, 1.0) var mouse_sensitivity = 0.01
@export var tilt_limit = deg_to_rad(75)
@onready var _animation_tree = %AnimationTree as AnimationTree
@onready var _model = %Model as Node3D
@onready var _state_machine = %StateMachine as StateMachine

const PLAYER_CAMERA = preload("res://main/player_camera.tscn")
const ACCELERATION = 20.0
const SPEED = 5.0
const JUMP_VELOCITY = 4.5
const ROTATION_SPEED = TAU * 2

var is_running = false
var last_direction := Vector3.BACK
var speed = SPEED
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

	is_running = Input.is_action_pressed("run")

	if is_running:
		speed = SPEED * 2
	else:
		speed = SPEED

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion && _player_camera:
		_player_camera.rotation.x -= event.relative.y * mouse_sensitivity
		_player_camera.rotation.x = clampf(_player_camera.rotation.x, -tilt_limit, tilt_limit)
		_player_camera.rotation.y += -event.relative.x * mouse_sensitivity
