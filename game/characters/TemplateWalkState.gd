extends State
"""
A type of State implementation used for walking state
"""

func process_state(delta: float):
	.process_state(delta)
	var move_direction = fsm._get_move_direction()
	
	if (move_direction.x != 0):
		var new_facing = sign(move_direction.x)
		entity.get_node('Body').scale.x = new_facing
		entity.facing = new_facing
	
	entity.velocity.x = lerp(entity.velocity.x, entity.move_speed.x * move_direction.x, 0.5)
	entity.velocity.y = lerp(entity.velocity.y, entity.move_speed.y * move_direction.y, 0.75)
	entity.do_movement_slide(entity.velocity)
	
	
func enter_state(prev_state: String):
	.enter_state(prev_state)
	entity.anim.play("walk")
	fsm.hitboxes.switch_to_area("Walk")
	
	
func exit_state(next_state: String):
	pass 
