extends CharacterView

class_name PlayerView

func _ready() -> void:
	$Skin.skeleton = model.get_skeleton().get_path()
