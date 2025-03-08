extends MarginContainer

func _on_reset_button_pressed():
	Signals.reset_game.emit()
