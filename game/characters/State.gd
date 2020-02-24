extends Node
class_name State
"""
Abstract state machine state interface. 
Nodes implementing this can be children of a state machine
"""
#reference to the hitbox groups timeline to animate hitbox groups
export(NodePath) var hitbox_areas_timeline_path
#group id for timeline processing
export(String) var hitbox_group_id: String = ""
#reference to the areas timeline if valid path provided
onready var hitbox_areas_timeline: AreaGroupTimeline = get_node(hitbox_areas_timeline_path)

# type should be derived from StateMachine, 
# not explicit due to cyclic type loading
var fsm
var entity: Node


func _ready():
	set_process(false)
	set_physics_process(false)


func process_state(delta: float):
	if (is_instance_valid(hitbox_areas_timeline)):
		hitbox_areas_timeline.process_timeline(hitbox_group_id, delta)
	
	
func enter_state(prev_state: String):
	if (is_instance_valid(hitbox_areas_timeline)):
		hitbox_areas_timeline.reset(hitbox_group_id)
	
	
func exit_state(next_state: String):
	pass 
	

func set_hitboxes_timeline(timeline_items: Array):
	assert(is_instance_valid(hitbox_areas_timeline))
	hitbox_areas_timeline.add_group_timeline(hitbox_group_id, timeline_items)
