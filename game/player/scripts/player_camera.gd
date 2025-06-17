class_name PlayerCamera extends Node3D

@export_range(0.0, 1.0) var mouse_sensitivity = 0.01
@export var tilt_limit = deg_to_rad(75)
var tilt_limit_min = 0.0

@onready var camera := %Camera as Camera3D

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		rotation.x -= event.relative.y * mouse_sensitivity
		rotation.x = clampf(rotation.x, tilt_limit_min, tilt_limit)
		rotation.y += -event.relative.x * mouse_sensitivity
