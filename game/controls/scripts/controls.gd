extends MarginContainer

func _ready() -> void:
	%LeftStick.stick_position_set.connect(_on_left_stick_position_set)

func _on_left_stick_position_set(position_: Vector2) -> void:
	%Debug.text = str(position_)

func _on_reset_button_pressed():
	Signals.reset_game.emit()
