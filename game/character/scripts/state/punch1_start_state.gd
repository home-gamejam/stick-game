extends CharacterState

class_name Punch1StartState

var animation_length: float
var combo_timer: float = 0.0
var max_combo: float
var min_combo: float

func _init(character_: Character) -> void:
	animation = "stickman_animations/Punch1Start"
	character = character_

func enter():
	animation_length = character.get_animation_length("stickman_animations/Punch1Start")
	min_combo = animation_length - 0.1
	max_combo = animation_length + 0.1
	combo_timer = 0.0

func physics_process(delta: float) -> CharacterState.Type:
	if Input.is_action_just_pressed("punch") and combo_timer >= min_combo and combo_timer <= max_combo:
		return CharacterState.Type.Punch2Start

	if not character.is_animation_playing() and combo_timer > max_combo:
		return CharacterState.Type.Punch1End

	combo_timer += delta

	character.move_based_on_input(delta, Vector2.ZERO)

	return CharacterState.Type.None
