extends Node3D

class_name CharacterView

@export var model: CharacterModel:
	set(model_):
		model = model_

func _physics_process(_delta: float) -> void:
	position = model.position
	global_rotation.y = model.rig.global_rotation.y