#@tool
extends Character

@export_range(0.0, 1.0) var mouse_sensitivity = 0.01
@export var tilt_limit = deg_to_rad(75)

const PLAYER_CAMERA = preload("res://player/player_camera.tscn")

var _player_camera: PlayerCamera

func _enter_tree():
	# this assumes that name was set to the pid
	var id = int(str(name))
	set_multiplayer_authority(id)

func _ready():
	if is_multiplayer_authority():
		_player_camera = PLAYER_CAMERA.instantiate()
		add_child(_player_camera)

func _physics_process(delta: float) -> void:
	character_model.update(get_input_data(), delta)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion && _player_camera:
		_player_camera.rotation.x -= event.relative.y * mouse_sensitivity
		_player_camera.rotation.x = clampf(_player_camera.rotation.x, -tilt_limit, tilt_limit)
		_player_camera.rotation.y += -event.relative.x * mouse_sensitivity

func get_input_data() -> InputData:
	var input_data = InputData.new()

	# TODO: If I remove update call for non-authority, may not need this check
	if is_multiplayer_authority():
		if Input.is_action_just_pressed("jump"):
			input_data.actions.append("jump")

		if Input.is_action_just_pressed("punch"):
			input_data.actions.append("punch")

		if Input.is_action_pressed("run"):
			input_data.actions.append("run")

		input_data.input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down", .1)

	return input_data

func get_forward_axis() -> Vector3:
	if not _player_camera:
		return super.get_forward_axis()

	return _player_camera.camera.global_basis.z

func get_right_axis() -> Vector3:
	if not _player_camera:
		return super.get_right_axis()

	return _player_camera.camera.global_basis.x
