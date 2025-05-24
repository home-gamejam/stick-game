extends Node3D

class_name PlayerView

@export var model: CharacterModel:
	set(model_):
		model = model_

func _ready() -> void:
	$Skin.skeleton = model.get_skeleton().get_path()
