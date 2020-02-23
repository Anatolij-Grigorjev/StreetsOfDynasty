extends State
class_name HurtState
"""
State in case the character was hurt with an attack. 
Convulse in pain and later recover
"""
export(float) var hurt_duration: float = 1.0
#reference to the attack groups timeline to animate attack groups
export(NodePath) var areas_timeline_path
#group id for timeline processing
export(String) var group_id: String = ""


var hurt_time: float = 0.0
var is_hurting: bool = false
#reference to hitboxes required to enable specific ones during hurting animation
var hitboxes: AreaGroup
#reference to the areas timeline if valid path provided
onready var areas_timeline: AreaGroupTimeline = get_node(areas_timeline_path)


func _ready():
	call_deferred("_set_hitboxes")


func process_state(delta: float):
	_check_still_hurting()
	if (is_instance_valid(areas_timeline)):
		areas_timeline.process_timeline(group_id, delta)
	hurt_time += delta
	

func _check_still_hurting():
	if (hurt_time >= hurt_duration):
		is_hurting = false

	
func enter_state(prev_state: String):
	is_hurting = true
	hurt_time = 0.0
	if (is_instance_valid(areas_timeline)):
		areas_timeline.reset(group_id)
	
	
func exit_state(next_state: String):
	entity.is_hurting = false
	
	
func _set_hitboxes():
	hitboxes = fsm.hitboxes


func set_group_timeline(timeline_items: Array):
	if (is_instance_valid(areas_timeline)):
		areas_timeline.add_group_timeline(group_id, timeline_items)
