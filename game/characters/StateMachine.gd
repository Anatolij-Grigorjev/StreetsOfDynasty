extends Node
class_name StateMachine
"""
Abstract state machine interface
"""
const NO_STATE: String = "<NO_STATE>"

export(String) var state: String = NO_STATE setget set_state
#default entity path is direct parent
export(NodePath) var entity_path: NodePath = NodePath("..")

var previous_state: String = NO_STATE
onready var entity: Node = get_node(entity_path)

var state_nodes = {}


func _ready() -> void:
	for node in get_children():
		var state = node as State
		if (state):
			state_nodes[state.name] = state
			state.fsm = self
			state.entity = entity
		

func _process(delta: float) -> void:
	if (state != NO_STATE):
		_process_state(delta)
		var next_state = _get_next_state(delta)
		if (next_state != NO_STATE):
			set_state(next_state)
	

func set_state(next_state: String) -> void:
	previous_state = state
	state = next_state
	
	if (previous_state != NO_STATE):
		_exit_state(previous_state, state)
		
	if (state != NO_STATE):
		_enter_state(state, previous_state)
		

func get_state(state_name: String) -> State:
	return state_nodes[state_name]
		
		
func _enter_state(next_state: String, prev_state: String):
	if (prev_state != NO_STATE):
		get_state(prev_state).exit_state(next_state)
	get_state(next_state).enter_state(prev_state)
	

func _exit_state(prev_state: String, next_state: String):
	get_state(prev_state).exit_state(next_state)
	if (next_state != NO_STATE):
		get_state(next_state).enter_state(prev_state)


func _process_state(delta: float) -> void:
	get_state(state).process_state(delta)


func _get_next_state(delta: float) -> String:
	return NO_STATE
