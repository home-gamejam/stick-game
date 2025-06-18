extends MarginContainer

func _ready() -> void:
	%LeftStick.stick_position_set.connect(_on_left_stick_position_set)
	%Restart.pressed.connect(_on_restart)

func _on_left_stick_position_set(position_: Vector2) -> void:
	%Debug.text = str(position_)

func _on_restart():
	if OS.get_name() == "Web":
		JavaScriptBridge.eval("reloadPage()")
	else:
		get_tree().change_scene_to_file("res://main/game.tscn")
