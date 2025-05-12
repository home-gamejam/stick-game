extends CharacterState

class_name Punch1StartState

var combo_timer: float = 0.0
var ended = false

var animation_length: float
var max_combo: float
var min_combo: float

func enter():
	animation_length = character.get_animation_length("stickman_animations/Punch1Start")
	min_combo = animation_length - 0.1
	max_combo = animation_length + 0.1

	character.play_animation("stickman_animations/Punch1Start")
	combo_timer = 0.0
	ended = false

func physics_process(delta: float) -> CharacterState.Type:
	if not character.is_animation_playing() and not ended:
		print(combo_timer)
		ended = true

	if Input.is_action_just_pressed("punch") and combo_timer >= min_combo and combo_timer <= max_combo:
		return CharacterState.Type.Punch2Start

	if not character.is_animation_playing() and combo_timer > max_combo:
		return CharacterState.Type.Punch1End

	combo_timer += delta

	return CharacterState.Type.None