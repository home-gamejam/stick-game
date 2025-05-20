extends Node3D

class_name World

const PLAYER_SCENE = preload("res://player/player.tscn")

func _ready():
	# If we start this as the main scene, add the player to start
	# automatically
	if get_parent() == get_tree().root:
		add_player(1)

func add_player(pid: int):
	print("[world] add_player: ", pid)
	var player = PLAYER_SCENE.instantiate()
	player.name = str(pid)
	var x = randi() % 10
	var z = randi() % 10
	player.position = Vector3(x, 1, z)

	%Players.add_child(player)
