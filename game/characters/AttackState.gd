extends State
class_name AttackState
"""
State to describe common parts of an attack in an attack chain
"""
#at what point cant switch from attack state before going into it
export(float) var attack_commit_start_sec := 0.0
#at what point can swithc out of attack recovery into next one
export(float) var attack_commit_end_sec := 0.93
#how long does the entire attack last
export(float) var attack_length_sec := 1.0


var attack_time: float = 0.0
#can the attack be changed into another state or combo?
var can_change_attack := true
#is the attack over and state should transition
var is_attack_over := true
#reference to attackboxes required to enable specific ones during attack
var attackboxes: AreaGroup
#reference to the name areagroup timeline node fo this attack state
#if this is valid, the state will follow a timeline
var areas_timeline_name: String
var areas_timeline_items: Array
var areas_timeline: AreaGroupTimeline


func _ready():
	call_deferred("_set_attackboxes")
	call_deferred("_set_timeline")


func process_state(delta: float):
	_check_can_change_attack()
	_check_attack_finished()
	if (is_instance_valid(areas_timeline)):
		areas_timeline.process_timeline(delta)
	for attackbox in attackboxes.get_enabled_areas():
		attackbox.process_attack()
	attack_time += delta

	
func _check_can_change_attack():
	if (can_change_attack and attack_time >= attack_commit_start_sec):
		can_change_attack = false
	if (not can_change_attack and attack_time >= attack_commit_end_sec):
		can_change_attack = true
		

func _check_attack_finished():
	if (not is_attack_over and attack_time >= attack_length_sec):
		_finish_attack()
	
	
func enter_state(prev_state: String):
	is_attack_over = false
	attack_time = 0.0
	if (is_instance_valid(areas_timeline)):
		areas_timeline.reset()


func _finish_attack():
	is_attack_over = true
	can_change_attack = true
	
	
func _set_attackboxes():
	attackboxes = fsm.attackboxes


func _set_timeline():
	if (areas_timeline_name):
		areas_timeline = attackboxes.find_node(areas_timeline_name) as AreaGroupTimeline
		if (areas_timeline_items):
			areas_timeline.areas_timeline = areas_timeline_items
	
