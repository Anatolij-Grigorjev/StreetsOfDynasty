extends Node
class_name State
"""
Abstract state machine state interface. 
Nodes implementing this can be children of a state machine
"""

onready var fsm: StateMachine = get_parent()



func _ready():
	set_process(false)
	set_physics_process(false)


func process_state(delta: float):
	pass
	
	
func enter_state(prev_state: String):
	pass
	
	
func exit_state(next_state: String):
	pass 