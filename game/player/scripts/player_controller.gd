#@tool
extends CharacterController

@export_range(0.0, 1.0) var mouse_sensitivity = 0.01
@export var tilt_limit = deg_to_rad(75)

const PLAYER_CAMERA = preload("res://player/player_camera.tscn")

var _player_camera: PlayerCamera

func _enter_tree():
	# this assumes that name was set to the pid
	var id = int(str(name))
	set_multiplayer_authority(id)

func _ready():
	if not is_multiplayer_authority():
		return

	_player_camera = PLAYER_CAMERA.instantiate()
	add_child(_player_camera)

	character_model.adjusted_basis = _player_camera.camera.global_basis

func _physics_process(delta: float) -> void:
	super._physics_process(delta)

	if _player_camera:
		_player_camera.position = character_model.position

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion && _player_camera:
		_player_camera.rotation.x -= event.relative.y * mouse_sensitivity
		_player_camera.rotation.x = clampf(_player_camera.rotation.x, -tilt_limit, tilt_limit)
		_player_camera.rotation.y += -event.relative.x * mouse_sensitivity
		character_model.adjusted_basis = _player_camera.camera.global_basis

func get_input() -> InputData:
	return InputData.get_current()
