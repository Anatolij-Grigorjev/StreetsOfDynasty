extends FiniteState
class_name HurtFiniteState
"""
Finite state specialization used for character hurt states
applied when state needs to inform root entity that hurt is over
"""


func exit_state(next_state: String):
	.exit_state(next_state)
	entity.is_hurting = false
