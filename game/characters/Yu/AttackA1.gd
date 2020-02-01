extends AttackState
"""
State describing first normal attack in character attack chain
"""

func process_state(delta: float):
	pass
	
	
func enter_state(prev_state: String):
	entity.anim.play("idle")
	fsm.hitboxes.switch_to_area("Idle")
	
	
func exit_state(next_state: String):
	pass 
