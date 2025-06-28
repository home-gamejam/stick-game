class_name WaitingRoom extends Node3D

@onready var ground_mesh: MeshInstance3D = %GroundMesh

const PLAYER_SCENE = preload("res://player/player.tscn")


func add_player(pid: int) -> void:
	print("[waiting_room] _on_player_added: ", pid)
	var player = PLAYER_SCENE.instantiate().init(pid)

	var size = ground_mesh.get_aabb().size / 2
	var x = randf_range(-size.x, size.x)
	var z = randf_range(-size.z, size.z)
	player.character_model.position = Vector3(x, 0, z)
	print("[waiting_room] position: ", player.character_model.position)

	%Players.add_child(player)

# Remove all players and return their peer ids
func remove_players() -> Array[int]:
	var pids: Array[int] = []

	for child: PlayerController in %Players.get_children():
		pids.append(child.pid)
		child.queue_free()

	return pids
