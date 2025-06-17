class_name CharacterView extends Node3D

func _ready() -> void:
	$Skin.skeleton = model.get_skeleton_path()

@export var model: CharacterModel:
	set(model_):
		model = model_
