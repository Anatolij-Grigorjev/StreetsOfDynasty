extends State
class_name AttackState
"""
State to describe common parts of an attack in an attack chain
"""
#at what point cant switch from attack state before going into it
var attack_commit_start_sec := 0.12
#at what point can swithc out of attack recovery into next one
var attack_commit_end_sec := 0.93
var attack_length_sec := 1.0

onready var attack_time : Stopwatch = $StateTime
var can_change_attack := true
var attack_over := true


func _ready():
	attack_time.wait_time = attack_length_sec


func process_state(delta: float):
	if (can_change_attack and attack_time.time_elapsed > attack_commit_start_sec):
		can_change_attack = false
	if (not can_change_attack and attack_time.time_elapsed > attack_commit_end_sec):
		can_change_attack = true
	
	
func enter_state(prev_state: String):
	attack_over = false
	attack_time.start()


func _on_StateTime_timeout():
	attack_over = true
	can_change_attack = true
