extends State


func process_state(delta: float):
	pass
	
	
func enter_state(prev_state: String):
	entity.anim.play("idle")
	pass
	
	
func exit_state(next_state: String):
	pass 
