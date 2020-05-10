extends State
class_name HurtStateAspect
"""
State aspect that ensures entity not in hurt state on state exit
"""

func exit_state(next_state: String):
	.exit_state(next_state)
	fsm.is_hurt_state = false
