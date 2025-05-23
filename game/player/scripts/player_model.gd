extends Node3D

class_name PlayerModel

@export var character: Character
@onready var _animation_player = %AnimationPlayer as AnimationPlayer
@onready var _animation_tree = %AnimationTree as AnimationTree

var current_state_type: CharacterState.Type = CharacterState.Type.Idle

var current_state: CharacterState:
	get:
		return states[current_state_type]

@onready var states: Dictionary[CharacterState.Type, CharacterState] = {
	CharacterState.Type.Fall: FallState.new(character),
	CharacterState.Type.FightIdle: FightIdleState.new(character),
	CharacterState.Type.Idle: IdleState.new(character),
	CharacterState.Type.Jump: JumpState.new(character),
	CharacterState.Type.Land: LandState.new(character),
	CharacterState.Type.Move: MoveState.new(character),
	CharacterState.Type.Punch1Start: Punch1StartState.new(character),
	CharacterState.Type.Punch1End: Punch1EndState.new(character),
	CharacterState.Type.Punch2Start: Punch2StartState.new(character),
}

var skeleton: Skeleton3D:
	get:
		return $rig/Skeleton3D

func _ready() -> void:
	update_state(current_state_type)

func play_animation(animation: String) -> void:
	match animation:
		"stickman_animations/Idle", "stickman_animations/Walk", "stickman_animations/Run":
			_animation_tree.active = true
			_animation_tree.set("parameters/Movement/blend_position", 0)

		_:
			_animation_tree.active = false
			_animation_player.play(animation)

# Corresponds to _physics_process on the character but delegates to the current
# state
func physics_process(delta: float) -> void:
	update_state(states[current_state_type].physics_process(delta))

# Corresponds to _unhandled_input on the character but delegates to the current
# state
func unhandled_input(event: InputEvent) -> void:
	update_state(states[current_state_type].unhandled_input(event))

func update_state(new_state_type: CharacterState.Type) -> void:
	# Only update if we have a new state
	if new_state_type == CharacterState.Type.None:
		return

	current_state.exit()

	current_state_type = new_state_type
	print("Transitioning to state: ", new_state_type)
	current_state.enter()
	play_animation(current_state.animation)
