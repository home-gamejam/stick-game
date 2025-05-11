extends CharacterBody3D

class_name Character

const MOVE_SPEED = 5.0
var move_speed = MOVE_SPEED
var last_input_dir := Vector2.ZERO
var last_rot_input_dir := Vector2.ZERO
var last_move_dir := Vector3.BACK
var last_rotation_dir := Vector3.BACK

var model: Node3D: get = get_model
func get_model() -> Node3D:
	return null

func get_forward_axis() -> Vector3:
	return -global_basis.z

func get_right_axis() -> Vector3:
	return -global_basis.x

func move_based_on_input(_delta: float, _input_dir: Vector2 = Vector2.ZERO, _rot_input_dir: Vector2 = _input_dir) -> void:
	pass

func set_animation_blend_position(_blend_position: Variant) -> void:
	pass

func is_animation_playing() -> bool:
	return false

func play_animation(_animation: String) -> void:
	pass