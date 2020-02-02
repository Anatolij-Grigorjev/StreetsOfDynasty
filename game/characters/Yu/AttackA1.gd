extends AttackState
"""
State describing first normal attack in character attack chain
"""

func process_state(delta: float):
	.process_state(delta)
	
	
func enter_state(prev_state: String):
	.enter_state(prev_state)
	entity.anim.play("attack_a1")
	fsm.hitboxes.switch_to_area("AttackA1")
	
	
func exit_state(next_state: String):
	.exit_state(next_state)
