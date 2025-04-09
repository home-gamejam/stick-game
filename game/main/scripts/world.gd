extends Node3D

class_name World

const PLAYER_SCENE = preload("res://main/player.tscn")


func add_player(pid: int):
	print("[world] add_player: ", pid)
	var player = PLAYER_SCENE.instantiate()
	player.name = str(pid)
	var x = randi() % 10
	var z = randi() % 10
	player.position = Vector3(x, 0, z)

	%Players.add_child(player)
