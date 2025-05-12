extends State

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

var character: Character

func get_input_dir() -> Vector2:
	return Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down", .1)
