extends Node

class_name CharacterController

@export var character_model: CharacterModel
@export var character_view: CharacterView
@export var acceleration: float = 20.0
@export var air_deceleration: float = 3
@export var rotation_speed = TAU * 2

func _physics_process(delta: float) -> void:
	# If this is not the authority, we don't process physics. The multiplayer
	# synchronizer will handle the movement and state updates.
	if not is_multiplayer_authority():
		return

	character_model.update(get_input(), delta)
	# character_view.global_rotation.y = character_model.global_rotation.y

# Override this for specific character types. E.g. player will use input from
# user inputs. Npcs will use AI inputs.
func get_input() -> InputData:
	return InputData.new()
