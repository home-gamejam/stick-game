extends HBoxContainer

func _ready():
	$SpeedFwd.value = Settings.player.speed_fwd
	$PortraitScale.value = Settings.camera.scale_portrait
	$LandscapeScale.value = Settings.camera.scale_landscape

	_update_rotate_screen_button()
	get_tree().root.size_changed.connect(_update_rotate_screen_button)

func _on_reset_button_pressed():
	Signals.reset_game.emit()

func _on_speed_fwd_value_changed(value):
	Settings.player.speed_fwd = value

func _on_portrait_scale_value_changed(value:float):
	Settings.camera.scale_portrait = value

func _on_landscape_scale_value_changed(value:float):
	Settings.camera.scale_landscape = value

func _on_flip_button_pressed():
	var window_size = DisplayServer.window_get_size()
	DisplayServer.window_set_size(Vector2i(window_size.y, window_size.x))
	_update_rotate_screen_button()

func _update_rotate_screen_button():
	$Buttons/RotateScreen.text = "L" if Game.is_landscape() else "P"
