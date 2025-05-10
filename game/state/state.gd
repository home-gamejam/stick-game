extends Node

class_name State

var character: Character

func enter() -> void:
	pass

func exit() -> void:
	pass

func get_input_dir() -> Vector2:
	return Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down", .1)

# Corresponds to _physics_process on the character but returns a State instance
# to transition to. Returning null indicates the state is unchanged.
func physics_process(_delta: float) -> State:
	return null

# Corresponds to _unhandled_input on the character but returns a State instance
# to transition to. Returning null indicates the state is unchanged.
func unhandled_input(_event: InputEvent) -> State:
	return null