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

func enter() -> void:
	pass

func exit() -> void:
	pass

func update(_input_data: InputData, _delta: float) -> CharacterState.Type:
	return CharacterState.Type.None
