extends StateMachine

class_name CharacterStateMachine

func get_initial_state_type() -> int:
	return CharacterState.Type.Idle

func get_states() -> Dictionary[int, State]:
	return {
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