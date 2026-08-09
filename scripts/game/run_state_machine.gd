class_name RunStateMachine
extends RefCounted

signal state_changed(previous: int, current: int)
enum State { IDLE, RUNNING, PAUSED, FAILED, COMPLETED }
var state: State = State.IDLE

func transition(next: State) -> bool:
	var valid := (state == State.IDLE and next == State.RUNNING) or (state == State.RUNNING and next in [State.PAUSED, State.FAILED, State.COMPLETED]) or (state == State.PAUSED and next in [State.RUNNING, State.IDLE]) or (state in [State.FAILED, State.COMPLETED] and next == State.IDLE)
	if not valid:
		return false
	var previous := state
	state = next
	state_changed.emit(previous, state)
	return true
