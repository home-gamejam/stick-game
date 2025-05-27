extends Node3D

class_name PlayerCamera

@export_range(0.0, 1.0) var mouse_sensitivity = 0.01
@export var tilt_limit = 0.5 # deg_to_rad(75)

@onready var camera := %Camera as Camera3D

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		rotation.x -= event.relative.y * mouse_sensitivity
		rotation.x = clampf(rotation.x, -tilt_limit, tilt_limit)
		rotation.y += -event.relative.x * mouse_sensitivity
