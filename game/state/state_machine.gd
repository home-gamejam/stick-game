extends Node

class_name StateMachine

@export var character: Character
@export var initial_state: State

var current_state: State = null

func init() -> void:
	assert(character != null, "Character must be set for StateMachine.")
	assert(initial_state != null, "Initial state must be set for StateMachine.")

	for child in get_children():
		if child is State:
			child.character = character

	update_state(initial_state)

func update_state(new_state: State) -> void:
	# Only update if we have a new state
	if new_state == null:
		return

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
