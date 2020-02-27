extends State
class_name WaitState
"""
State to wait certain amount with 
a specific animation before moving to another state
"""

export(float) var wait_time: float = 1.0
export(String) var wait_animation: String
export(String) var wait_hitbox: String
export(String) var next_state: String = StateMachine.NO_STATE

var current_wait: float = wait_time
var waiting_over := false


func process_state(delta: float):
	.process_state(delta)
	if (not waiting_over):
		current_wait -= delta
	if (not waiting_over and current_wait <= 0.0):
		waiting_over = true
	
	
func enter_state(prev_state: String):
	.enter_state(prev_state)
	entity.anim.play(wait_animation)
	if (wait_hitbox):
		fsm.hitboxes.switch_to_area(wait_hitbox)
	current_wait = wait_time
	waiting_over = false
	
	
func exit_state(next_state: String):
	.exit_state(next_state)
