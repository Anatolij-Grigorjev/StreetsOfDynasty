extends State
class_name MovedStateAspect
"""
A state aspect that allows a character to moved by 
a controlled motion with aspects like facing/speed/etc 
set by the external mover
"""


enum Easing {
	GENTLE = 0,
	HALFWAY = 1,
	ALL_IN = 2
}
export(Vector2) var move_impulse: Vector2 = Vector2.ZERO
export(Easing) var move_easing: int = Easing.HALFWAY


var easing_lerp_coef: Dictionary = {
	Easing.GENTLE: 0.15,
	Easing.HALFWAY: 0.51,
	Easing.ALL_IN: 0.95
}


func process_state(delta: float):
	.process_state(delta)
	var lerp_coef = easing_lerp_coef[move_easing]
	
	entity.velocity.x = lerp(entity.velocity.x, move_impulse.x, lerp_coef)
	entity.velocity.y = lerp(entity.velocity.y, move_impulse.y, lerp_coef)
	entity.do_movement_collide(entity.velocity * delta)
