extends Node

class_name CharacterState

enum Type {
	None = 0,
	Idle,
	Fall,
	FightIdle,
	Jump,
	Land,
	Move,
	Punch1Start,
	Punch1End,
	Punch2Start,
}

var animation: String
var character_model: CharacterModel
var character_body: Character:
	get:
		return character_model.character_body

func get_input_dir() -> Vector2:
	return Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down", .1)

func enter() -> void:
	pass

func exit() -> void:
	pass

# Corresponds to _physics_process on the character_model but returns a CharacterState instance
# to transition to. Returning CharacterState.Type.None indicates the state is unchanged.
func physics_process(_delta: float) -> CharacterState.Type:
	return CharacterState.Type.None

# Corresponds to _unhandled_input on the character_model but returns a CharacterState instance
# to transition to. Returning CharacterState.Type.None indicates the state is unchanged.
func unhandled_input(_event: InputEvent) -> CharacterState.Type:
	return CharacterState.Type.None