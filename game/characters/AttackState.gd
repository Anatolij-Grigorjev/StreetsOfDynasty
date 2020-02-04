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
"""
Timeline of timebox activations during this attack.
A timeline item can be described as the object:
	{
		time: 0.34, <-- point to do action
		enable: false, <-- flag to disable or enable the attackbox
		attackbox: "A1" <-- name of attackbox to feed into area group
	}
"""
var attackbox_timeline := []
var timeline_idx := 0

func process_state(delta: float):
	_check_can_change_attack()
	_check_attack_finished()
	_apply_attackbox_timeline()
	for attackbox in attackboxes.get_enabled_areas():
		attackbox.process_attack()
	attack_time += delta
	
	
func _apply_attackbox_timeline():
	if (timeline_idx >= attackbox_timeline.size()):
		return
	while (
		timeline_idx < attackbox_timeline.size()
		and attackbox_timeline[timeline_idx].time < attack_time
	):
		_apply_attackbox_timeline_item(attackbox_timeline[timeline_idx])
		timeline_idx += 1


func _apply_attackbox_timeline_item(timeline_item: Dictionary):
	if (timeline_item.enable):
		attackboxes.enable_area(timeline_item.attackbox)
	else:
		attackboxes.disable_area(timeline_item.attackbox)

	
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
	timeline_idx = 0


func _finish_attack():
	is_attack_over = true
	can_change_attack = true
	
