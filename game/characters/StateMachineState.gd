extends State
class_name StateMachineState
"""
A type of state that manages an internal FSM that handles substates
Distinct from having a state with composite state aspects
"""
export(String) var initial_state := StateMachine.NO_STATE

onready var sub_fsm: StateMachine = get_node("FSM")

"""
set by sub FSM to exit this state
"""
var sub_fsm_over: bool = false

func process_state(delta: float):
	.process_state(delta)
	sub_fsm._process(delta)
	
	
func enter_state(prev_state: String):
	.enter_state(prev_state)
	#start FSM
	sub_fsm.state = initial_state
	
	
func exit_state(next_state: String):
	.exit_state(next_state)
	#stop FSM
	sub_fsm.state = StateMachine.NO_STATE
	sub_fsm_over = false
