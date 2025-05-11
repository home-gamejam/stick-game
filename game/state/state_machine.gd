extends Node

class_name StateMachine

"""
State machine for a character.
"""

@export var character: Character

var initial_state_type: int
var states: Dictionary[int, State] = {}
var current_state: State = null


func init() -> void:
	initial_state_type = get_initial_state_type()
	states = get_states()

	assert(character != null, "Character must be set for StateMachine.")
	assert(initial_state_type != State.Type.None, "Initial state must be set for StateMachine.")

	for child in states.values():
		if child is State:
			child.character = character

	update_state(initial_state_type)

# This should be overridden by a subclass state machine
func get_initial_state_type() -> int:
	assert(false, "get_initial_state_type() must be implemented in a subclass")
	return State.Type.None

# This should be overridden by a subclass state machine
func get_states() -> Dictionary[int, State]:
	assert(false, "get_states() must be implemented in a subclass")
	return {}

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
