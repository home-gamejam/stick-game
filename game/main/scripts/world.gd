class_name World extends Node3D

const PLAYER_SCENE = preload("res://player/player.tscn")

func _ready():
	# If we start this as the main scene, add the player to start
	# automatically
	if get_parent() == get_tree().root:
		add_player(1)

func add_player(pid: int):
	print("[world] add_player: ", pid)
	var player: PlayerController = PLAYER_SCENE.instantiate()
	player.name = str(pid)
	var x = randi() % 10
	var z = randi() % 10
	player.character_model.position = Vector3(x, 1, z)
	player.throw_ball.connect(_on_throw.bind(player))

	%Players.add_child(player)

func _on_throw(player: PlayerController) -> void:
	var ball: Ball = Ball.spawn(player.character_model.rig)
	%Objects.add_child(ball)
