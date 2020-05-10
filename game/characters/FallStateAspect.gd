extends State
class_name FallStateAspect
"""
State aspect that ensures entity not in fall state on state exit
"""

func exit_state(next_state: String):
	.exit_state(next_state)
	fsm.is_fall_state = false
