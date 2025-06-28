class_name PlayerController extends CharacterController

const BALL = preload("res://objects/ball.tscn")
const PLAYER_CAMERA = preload("res://player/player_camera.tscn")

var pid: int
var _player_camera: PlayerCamera

func init(pid_: int) -> PlayerController:
	pid = pid_
	# Encode the pid in the name so that multiplayer synchronizer can match
	# nodes across peers. This is important since player nodes won't get added
	# to Players node in the same order in each peer, so auto generated names
	# won't match.
	name = "Player (%s)" % pid
	return self

func _enter_tree():
	set_multiplayer_authority(pid)

func _ready():
	if not is_multiplayer_authority():
		set_physics_process(false)
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
		_on_throw()

func _on_throw() -> void:
	var ball: Ball = %ObjectSpawner.spawn(pid)

	ball.launch(character_model.rig)
