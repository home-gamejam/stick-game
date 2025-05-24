extends Node3D

class_name CharacterModel

@export var character_body: Character
@onready var animation_player = %AnimationPlayer as AnimationPlayer
@onready var animation_tree = %AnimationTree as AnimationTree

var current_state_type: CharacterState.Type = CharacterState.Type.Idle

var current_state: CharacterState:
	get:
		return states[current_state_type]

@onready var states: Dictionary[CharacterState.Type, CharacterState] = {
	CharacterState.Type.Fall: FallState.new(self),
	CharacterState.Type.FightIdle: FightIdleState.new(self),
	CharacterState.Type.Idle: IdleState.new(self),
	CharacterState.Type.Jump: JumpState.new(self),
	CharacterState.Type.Land: LandState.new(self),
	CharacterState.Type.Move: MoveState.new(self),
	CharacterState.Type.Punch1Start: Punch1StartState.new(self),
	CharacterState.Type.Punch1End: Punch1EndState.new(self),
	CharacterState.Type.Punch2Start: Punch2StartState.new(self),
}

func _ready() -> void:
	_update_state(current_state_type)

func _update_state(new_state_type: CharacterState.Type) -> void:
	# Only update if we have a new state
	if new_state_type == CharacterState.Type.None:
		return

	current_state.exit()

	print("Transitioning state from ", current_state_type, " to ", new_state_type)
	current_state_type = new_state_type
	current_state.enter()
	play_animation(current_state.animation)

func get_animation_length(animation: String) -> float:
	return animation_player.get_animation(animation).length

func get_skeleton() -> Skeleton3D:
	return $rig/Skeleton3D

func is_animation_playing() -> bool:
	return animation_player.is_playing()

func play_animation(animation: String) -> void:
	match animation:
		"stickman_animations/Idle", "stickman_animations/Walk", "stickman_animations/Run":
			animation_tree.active = true
			animation_tree.set("parameters/Movement/blend_position", 0)

		_:
			animation_tree.active = false
			animation_player.play(animation)

func set_animation_blend_position(blend_position: Variant) -> void:
	animation_tree.set("parameters/Movement/blend_position", blend_position)

# Update the character state based on input data and delta time
func update(input_data: InputData, delta: float) -> void:
	_update_state(current_state.update(input_data, delta))
