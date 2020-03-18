extends State
class_name WalkStateAspect
"""
State aspect that processes entity velocity and facing information
into lerped motion
"""

"""
move speed via this aspect. 
if this is 0 then the entity move speed is used
"""
export(Vector2) var move_speed: Vector2 = Vector2.ZERO
export(bool) var change_facing: bool = true


func process_state(delta: float):
	.process_state(delta)
	var move_speed = (self.move_speed 
					if self.move_speed != Vector2.ZERO 
					else entity.move_speed)
					
	var move_direction = fsm._get_move_direction()
	if (move_direction.x != 0 and change_facing):
		var new_facing = sign(move_direction.x)
		entity.get_node('Body').scale.x = new_facing
		entity.facing = new_facing
	
	entity.velocity.x = lerp(entity.velocity.x, move_speed.x * move_direction.x, 0.5)
	entity.velocity.y = lerp(entity.velocity.y, move_speed.y * move_direction.y, 0.75)
	entity.do_movement_slide(entity.velocity)
