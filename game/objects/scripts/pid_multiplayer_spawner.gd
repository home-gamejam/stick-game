class_name PidMultiplayerSpawner extends MultiplayerSpawner

@export var packed_scene: PackedScene

func _enter_tree() -> void:
	spawn_function = spawn_node

func spawn_node(pid: Variant) -> Node:
	return packed_scene.instantiate().init(pid)
