extends Node

class_name State

const NoneType = 0

func enter() -> void:
	pass

func exit() -> void:
	pass

# Corresponds to _physics_process on the character but returns a CharacterState instance
# to transition to. Returning CharacterState.Type.None indicates the state is unchanged.
func physics_process(_delta: float) -> int:
	return CharacterState.Type.None

# Corresponds to _unhandled_input on the character but returns a CharacterState instance
# to transition to. Returning CharacterState.Type.None indicates the state is unchanged.
func unhandled_input(_event: InputEvent) -> int:
	return CharacterState.Type.None
