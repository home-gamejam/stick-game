extends Control

@export var action: String

func _ready() -> void:
	%TouchScreenButton.action = action
