extends Node

class_name CharacterController

@export var input_source: InputSource
@export var character_model: CharacterModel
@export var character_view: CharacterView
@export var acceleration: float = 20.0
@export var air_deceleration: float = 3
@export var rotation_speed = TAU * 2

var input: InputData = InputData.new()

func _physics_process(delta: float) -> void:
	# If this is not the authority, we don't process physics. The multiplayer
	# synchronizer will handle the movement and state updates.
	if not is_multiplayer_authority():
		return

	input = input_source.get_input()
	character_model.update(input, delta)
	# character_view.global_rotation.y = character_model.global_rotation.y
