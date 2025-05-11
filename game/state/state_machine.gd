extends Node

class_name StateMachine

"""
State machine for a character.
"""

@export var character: Character
@export var initial_state: CharacterState.Type

var states: Dictionary[int, State] = {
	CharacterState.Type.Fall: FallState.new(),
	CharacterState.Type.FightIdle: FightIdleState.new(),
	CharacterState.Type.Idle: IdleState.new(),
	CharacterState.Type.Jump: JumpState.new(),
	CharacterState.Type.Land: LandState.new(),
	CharacterState.Type.Move: MoveState.new(),
	CharacterState.Type.Punch1Start: Punch1StartState.new(),
	CharacterState.Type.Punch1End: Punch1EndState.new(),
	CharacterState.Type.Punch2Start: Punch2StartState.new(),
}

var current_state: State = null

func init() -> void:
	assert(character != null, "Character must be set for StateMachine.")
	assert(initial_state != State.Type.None, "Initial state must be set for StateMachine.")

	for child in states.values():
		if child is State:
			child.character = character

	update_state(initial_state)

func update_state(new_state_type: int) -> void:
	# Only update if we have a new state
	if new_state_type == State.Type.None:
		return

	var new_state := states[new_state_type]

	if current_state != null:
		current_state.exit()

	current_state = new_state
	print("Transitioning to state: ", current_state.name)
	current_state.enter()

# Corresponds to _physics_process on the character but delegates to the current
# state
func physics_process(delta: float) -> void:
	update_state(current_state.physics_process(delta))

# Corresponds to _unhandled_input on the character but delegates to the current
# state
func unhandled_input(event: InputEvent) -> void:
	update_state(current_state.unhandled_input(event))
