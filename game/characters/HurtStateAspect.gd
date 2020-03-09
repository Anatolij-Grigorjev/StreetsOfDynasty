extends State
class_name HurtStateAspect
"""
State aspect that ensures entity not hurting on state exit
"""

func exit_state(next_state: String):
	.exit_state(next_state)
	entity.is_hurting = false
