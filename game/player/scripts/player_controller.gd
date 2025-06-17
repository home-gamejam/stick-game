extends CharacterController

const PLAYER_CAMERA = preload("res://player/player_camera.tscn")

var _player_camera: PlayerCamera

func _enter_tree():
	# this assumes that name was set to the pid
	var id = int(str(name))
	set_multiplayer_authority(id)

func _ready():
	if not is_multiplayer_authority():
		return

	# Only create camera if this is multiplayer authority
	_player_camera = PLAYER_CAMERA.instantiate()
	add_child(_player_camera)

func _physics_process(delta: float) -> void:
	super._physics_process(delta)

	if _player_camera:
		# sync player model and camera (Note _player_camera vs _player_camera.camera)
		_player_camera.position = character_model.position
		character_model.adjusted_basis = _player_camera.camera.global_transform.basis
		character_model.adjusted_rotation = _player_camera.camera.global_rotation.y

	character_view.position = character_model.position
	character_view.global_rotation.y = character_model.rig.global_rotation.y

	if input.action == InputData.Action.Punch:
		print("Punching.....")
