extends CharacterBody3D

class_name Character

const MOVE_SPEED = 5.0
var move_speed = MOVE_SPEED
var last_direction := Vector3.BACK
var last_input_direction := Vector2.ZERO

var model: Node3D: get = get_model
func get_model() -> Node3D:
	return null

func get_forward_axis() -> Vector3:
	return -global_basis.z

func get_right_axis() -> Vector3:
	return -global_basis.x

func move_based_on_input(_delta: float, _input_dir: Vector2 = Vector2.ZERO) -> void:
	pass

func set_animation_blend_position(_blend_position: int) -> void:
	pass

func play_animation(_animation: String) -> void:
	pass