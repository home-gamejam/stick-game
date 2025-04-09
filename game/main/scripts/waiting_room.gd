extends Node3D

class_name WaitingRoom

const PLAYER_SCENE = preload("res://main/player.tscn")


func add_player(pid: int):
	print("[waiting_room] _on_player_added: ", pid)
	var player = PLAYER_SCENE.instantiate()
	player.name = str(pid)
	var x = randi() % 10
	var z = randi() % 10
	player.position = Vector3(x, 0, z)

	%Players.add_child(player)

# Remove all players and return their peer ids
func remove_players() -> Array[int]:
	var pids: Array[int] = []

	for child in %Players.get_children():
		pids.append(child.name.to_int())
		child.queue_free()

	return pids
