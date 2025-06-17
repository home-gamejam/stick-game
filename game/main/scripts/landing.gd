extends VBoxContainer

signal play_pressed()
signal multiplayer_pressed()

func _ready() -> void:
	%Play.pressed.connect(_on_play_pressed)
	%Multiplayer.pressed.connect(_on_multiplayer_pressed)

	%UpdateGame.visible = OS.get_name() == "Web"
	if %UpdateGame.visible:
		%UpdateGame.pressed.connect(_on_update_game)

func _on_play_pressed() -> void:
	play_pressed.emit()

func _on_multiplayer_pressed() -> void:
	multiplayer_pressed.emit()

func _on_update_game():
	JavaScriptBridge.eval("updateServiceWorker()")
