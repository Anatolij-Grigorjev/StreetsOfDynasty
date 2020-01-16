extends Node
"""
Abstract state machine interface
"""
const NO_STATE: String = "<NO_STATE>"

export(String) var state: String = NO_STATE setget set_state
export(NodePath) var entity_path: NodePath

var previous_state: String = NO_STATE
onready var entity: Node = get_node(entity_path)

var states = {}


func _process(delta: float) -> void:
	if (state != NO_STATE):
		_process_state(delta)
		var next_state = _get_next_state(delta)
		if (next_state != NO_STATE):
			set_state(next_state)


func add_state(new_state: String) -> void:
	states[new_state] = states.size()


func exit_state(prev_state: String, next_state: String) -> void:
	pass


func enter_state(next_state: String, prev_state: String) -> void:
	pass
	

func set_state(next_state) -> void:
	previous_state = state
	state = next_state
	
	if (previous_state != NO_STATE):
		exit_state(previous_state, state)
		
	if (state != NO_STATE):
		enter_state(state, previous_state)
		
		
func _process_state(delta: float) -> void:
	pass


func _get_next_state(delta: float) -> String:
	return NO_STATE