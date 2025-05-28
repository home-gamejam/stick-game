extends Node3D

class_name CharacterView

func _ready() -> void:
	$Skin.skeleton = model.get_skeleton_path()

@export var model: CharacterModel:
	set(model_):
		model = model_
