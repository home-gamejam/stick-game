extends Node3D

class_name WaitingRoom

@onready var ground_mesh: MeshInstance3D = %GroundMesh

const PLAYER_SCENE = preload("res://main/player.tscn")


func add_player(pid: int):
	print("[waiting_room] _on_player_added: ", pid)
	var player = PLAYER_SCENE.instantiate()
	player.name = str(pid)

	var size = ground_mesh.get_aabb().size / 2
	var x = randf_range(-size.x, size.x)
	var z = randf_range(-size.z, size.z)
	player.position = Vector3(x, 0, z)
	print("[waiting_room] position: ", player.position)

	%Players.add_child(player)

# Remove all players and return their peer ids
func remove_players() -> Array[int]:
	var pids: Array[int] = []

	for child in %Players.get_children():
		pids.append(child.name.to_int())
		child.queue_free()

	return pids
