extends State
"""
A type of State implementation used for walking state
"""

func process_state(delta: float):
	var move_direction = fsm._get_move_direction()
	
	if (move_direction.x != 0):
		entity.get_node('Body').scale.x = sign(move_direction.x)
	
	entity.velocity.x = lerp(entity.velocity.x, entity.move_speed.x * move_direction.x, 0.5)
	entity.velocity.y = lerp(entity.velocity.y, entity.move_speed.y * move_direction.y, 0.75)
	entity.velocity = entity.move_and_slide(entity.velocity, Vector2.UP)
	
	
func enter_state(prev_state: String):
	entity.anim.play("walk")
	
	
func exit_state(next_state: String):
	pass 
