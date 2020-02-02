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


func process_state(delta: float):
	if (can_change_attack and attack_time >= attack_commit_start_sec):
		can_change_attack = false
	if (not can_change_attack and attack_time >= attack_commit_end_sec):
		can_change_attack = true
	if (not is_attack_over and attack_time >= attack_length_sec):
		_finish_attack()
	attack_time += delta
	
	
func enter_state(prev_state: String):
	is_attack_over = false
	attack_time = 0.0


func _finish_attack():
	is_attack_over = true
	can_change_attack = true
	
