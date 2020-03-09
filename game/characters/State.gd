extends Node
class_name State
"""
Abstract state machine state interface. 
Nodes implementing this can be children of a state machine
This node allows referencing the parent state machine and root entity
turns off physics by default to get processed via FSM

"""
# type should be derived from StateMachine, 
# not explicit due to cyclic type loading
var fsm setget _set_fsm
var entity: Node setget _set_entity


onready var state_aspects: Array = get_children()


func _ready():
	set_process(false)
	set_physics_process(false)


func process_state(delta: float):
	for aspect in state_aspects:
		aspect.process_state(delta)
	
	
func enter_state(prev_state: String):
	for aspect in state_aspects:
		aspect.enter_state(prev_state)
	
	
func exit_state(next_state: String):
	for aspect in state_aspects:
		aspect.exit_state(next_state)
		
		
func _set_fsm(set_fsm):
	fsm = set_fsm
	for aspect in state_aspects:
		aspect.fsm = set_fsm


func _set_entity(set_entity: Node):
	entity = set_entity
	for aspect in state_aspects:
		aspect.entity = set_entity
