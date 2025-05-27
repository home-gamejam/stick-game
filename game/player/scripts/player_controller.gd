#@tool
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
	_player_camera.model = character_model
	add_child(_player_camera)

func get_input() -> InputData:
	return InputData.get_current()
