extends StateMachine
"""
A FSM for Yu catching substates
"""


onready var parent_state: StateMachineState = get_parent()

var caught_character: CharacterTemplate setget _set_caught_character


func _ready():
	set_process(false)
	set_physics_process(false)
	

func set_state(next_state: String):
	.set_state(next_state)
	if (entity and is_instance_valid(entity.LOG)):
		entity.LOG.info("'{}' -> '{}'", [previous_state, next_state])
	
	
func _get_next_state(delta: float) -> String:
	
	
	match(state):
		"CatchIdle":
			var catch_idle_state := get_state(state) as FiniteState
			if (not catch_idle_state.is_state_over):
				return NO_STATE
			return catch_idle_state.next_state
		_:
			breakpoint
			return NO_STATE


"""
set caught character context for all substates
"""
func _set_caught_character(character: CharacterTemplate):
	for state_name in state_nodes:
		var state_node = get_state(state_name) as State
		for aspect in state_node.state_aspects:
			if (aspect is CatchingStateAspect):
				aspect.caught_character = character
