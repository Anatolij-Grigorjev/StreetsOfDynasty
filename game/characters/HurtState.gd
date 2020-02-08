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
#reference to the name areagroup timeline node fo this hurting state
#if this is valid, the state will follow a timeline
var areas_timeline_name: String
var areas_timeline_items: Array
var areas_timeline: AreaGroupTimeline


func _ready():
	call_deferred("_set_hitboxes")
	call_deferred("_set_timeline")


func process_state(delta: float):
	_check_still_hurting()
	if (is_instance_valid(areas_timeline)):
		areas_timeline.process_timeline(delta)
	hurt_time += delta
	

func _check_still_hurting():
	if (hurt_time >= hurt_duration):
		is_hurting = false

	
func enter_state(prev_state: String):
	is_hurting = true
	hurt_time = 0.0
	if (is_instance_valid(areas_timeline)):
		areas_timeline.reset()
	
	
func exit_state(next_state: String):
	entity.is_hurting = false
	
	
func _set_hitboxes():
	hitboxes = fsm.hitboxes


func _set_timeline():
	if (areas_timeline_name):
		areas_timeline = hitboxes.find_node(areas_timeline_name) as AreaGroupTimeline
		if (areas_timeline_items):
			areas_timeline.areas_timeline = areas_timeline_items
