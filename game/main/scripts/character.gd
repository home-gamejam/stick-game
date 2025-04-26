extends CharacterBody3D

class_name Character

var last_direction := Vector3.BACK

var model: Node3D: get = get_model
func get_model() -> Node3D:
	return null

func get_direction(input_dir: Vector2) -> Vector3:
	var forward := -global_basis.z
	var right := -global_basis.x

	var direction := forward * input_dir.y + right * input_dir.x

	return direction.normalized()

func set_animation_blend_position(_blend_position: int) -> void:
	pass

func play_animation(_animation: String) -> void:
	pass