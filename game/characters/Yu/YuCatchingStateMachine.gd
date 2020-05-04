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
			caught_character.is_caught = false
			parent_state.sub_fsm_over = true
			return NO_STATE
		_:
			breakpoint
			return NO_STATE


"""
set caught character context for all substates
"""
func _set_caught_character(character: CharacterTemplate):
	caught_character = character
	caught_character.is_caught = true
	_align_caught_catch_points()


func _align_caught_catch_points():
	#make them look at each other
	caught_character.facing = -1 * entity.facing
	
	var caught_pos: Vector2 = caught_character.caught_point.global_position
	var catch_pos: Vector2 = entity.catch_point.global_position
	var directed_move: Vector2 = caught_pos.direction_to(catch_pos) * caught_pos.distance_to(catch_pos)
	caught_character.global_position += directed_move
	#reduce y to catcher
	caught_character.global_position.y = entity.global_position.y
