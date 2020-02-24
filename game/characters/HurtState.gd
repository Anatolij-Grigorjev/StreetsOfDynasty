extends State
class_name HurtState
"""
State in case the character was hurt with an attack. 
Convulse in pain and later recover
"""
export(float) var hurt_duration: float = 1.0


var hurt_time: float = 0.0
var is_hurting: bool = false
#reference to hitboxes required to enable specific ones during hurting animation
var hitboxes: AreaGroup


func _ready():
	call_deferred("_set_hitboxes")


func process_state(delta: float):
	.process_state(delta)
	_check_still_hurting()
	hurt_time += delta
	

func _check_still_hurting():
	if (hurt_time >= hurt_duration):
		is_hurting = false

	
func enter_state(prev_state: String):
	.enter_state(prev_state)
	is_hurting = true
	hurt_time = 0.0
	
	
func exit_state(next_state: String):
	entity.is_hurting = false
	
	
func _set_hitboxes():
	hitboxes = fsm.hitboxes
