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
	Debug.log_info("'{}' -> '{}'", [previous_state, next_state])
	
	
func _get_next_state(delta: float) -> String:
	
	var attack_input: int = _get_attack_input()
	
	match(state):
		"CatchIdle":
			var catch_idle_state := get_state(state) as FiniteState
			if (attack_input == C.AttackInputType.NORMAL):
				return "CatchAttack"
				
			if (not catch_idle_state.is_state_over):
				return NO_STATE
				
			_end_sub_fsm()
			return NO_STATE
		"CatchAttack":
			var finite_state = state_nodes[state] as FiniteState
			if (not finite_state.is_state_over):
				return NO_STATE
				
			caught_character.emit_signal("got_released", "Hurt")
			parent_state.next_parent_state = "AttackA2"
			_end_sub_fsm()
			return finite_state.next_state
		_:
			breakpoint
			return NO_STATE


"""
set caught character context for all substates
"""
func _set_caught_character(character: CharacterTemplate):
	#had somebody also caught
	if (is_instance_valid(caught_character)):
		caught_character.emit_signal("got_released", "Idle")
	caught_character = character
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


func _get_attack_input() -> int:
	if (Input.is_action_just_pressed("attack_normal")):
		return C.AttackInputType.NORMAL
	return C.AttackInputType.NONE
	
	
func _end_sub_fsm():
	parent_state.sub_fsm_over = true
	caught_character = null
