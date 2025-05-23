extends Node3D

class_name CharacterModel

@export var character_body: Character

func get_animation_length(_animation: String) -> float:
	return 0.0

func get_skeleton() -> Skeleton3D:
	return null

func is_animation_playing() -> bool:
	return false

func set_animation_blend_position(_blend_position: Variant) -> void:
	pass
