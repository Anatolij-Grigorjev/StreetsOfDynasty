extends CharacterStateMachineTemplate
"""
Yu main state machine
"""


signal next_attack_input_changed(next_attack_input)


var next_attack_input: int = C.AttackInputType.NONE
var has_caught := SingleReadVar.new(false)


func _ready():
	call_deferred("set_state", "Idle")
	

func set_state(next_state: String):
	.set_state(next_state)
	Debug.log_info("{}: '{}' -> '{}'", [owner, previous_state, next_state])
		
		
func _process(delta):
	pass
	
	
func _get_next_state(delta: float) -> String:
	var move_direction = _get_move_direction()
	var attack_input: int = _get_attack_input()
	var hurting: bool = Debug.get_debug1_pressed()
	
	var is_catching = has_caught.read_and_reset()
	
	match(state):
		"Idle":
			if (hurting):
				return "HurtLow"
			if (move_direction != Vector2.ZERO):
				return "Walk"
			if (attack_input == C.AttackInputType.NORMAL):
				return "AttackA1"
			return NO_STATE
		"Walk":
			if (hurting):
				return "HurtLow"
			if (move_direction == Vector2.ZERO):
				return "Idle"
			if (attack_input == C.AttackInputType.NORMAL):
				return "AttackA1"
			if (is_catching):
				return "Catching"
			return NO_STATE
		"AttackA1":
			if (hurting):
				return "HurtLow"
			var attack_state = state_nodes[state] as FiniteState
			_cache_next_attack_input(attack_input, attack_state)
			if (not attack_state.can_change_state):
				return NO_STATE
			if (next_attack_input == C.AttackInputType.NORMAL):
				_clear_next_attack_input()
				return "AttackA2"
			if (move_direction != Vector2.ZERO):
				return "Walk"
			if (attack_state.is_state_over):
				return _next_or_default(attack_state)
			return NO_STATE
		"AttackA2":
			if (hurting):
				return "HurtLow"
			var attack_state = state_nodes[state] as FiniteState
			if (not attack_state.can_change_state):
				return NO_STATE
			if (move_direction != Vector2.ZERO):
				return "Walk"
			if (attack_state.is_state_over):
				return _next_or_default(attack_state)
			return NO_STATE
		"Catching":
			var catching_state = state_nodes[state] as StateMachineState
			if (not catching_state.sub_fsm_over):
				return NO_STATE
			#reset sub fsm state after read
			catching_state.sub_fsm_over = false
			return catching_state.next_parent_state
		"HurtLow":
			var hurt_state = state_nodes[state] as FiniteState
			if (not hurt_state.is_state_over):
				return NO_STATE
			return _next_or_default(hurt_state)
		_:
			breakpoint
			return NO_STATE


func _get_move_direction() -> Vector2:
	var move_direction_horiz = -int(Input.is_action_pressed("move_left")) + int(Input.is_action_pressed("move_right"))
	var move_direction_vert = -int(Input.is_action_pressed("move_up")) + int(Input.is_action_pressed("move_down"))
	
	return Vector2(move_direction_horiz, move_direction_vert).normalized()
	
	
func _get_attack_input() -> int:
	if (Input.is_action_just_pressed("attack_normal")):
		return C.AttackInputType.NORMAL
	return C.AttackInputType.NONE
	
	
func _clear_next_attack_input():
	next_attack_input = C.AttackInputType.NONE
	emit_signal("next_attack_input_changed", next_attack_input)
			
			
func _cache_next_attack_input(attack_input: int, attack_state: FiniteState):
	var attack_phase_aspect = attack_state.get_node('AttackStatePhaseAspect')
	if (not attack_phase_aspect):
		print(state, " requires a AttackStatePhaseAspect child!")
		breakpoint
	if (
		attack_phase_aspect.attack_phase != C.AttackPhase.WIND_UP
		and attack_input != C.AttackInputType.NONE
	):
		next_attack_input = attack_input
		emit_signal("next_attack_input_changed", next_attack_input)


func _on_character_caught_character(caught: CharacterTemplate):
	if (_can_start_catching()):
		var catching_fsm = $Catching/FSM
		catching_fsm.caught_character = caught
		has_caught.current_value = true
		

func _can_start_catching() -> bool:
	return state == "Walk"


func _next_or_default(state: FiniteState, default: String = "Idle") -> String:
	if (state.next_state):
		return state.next_state
	else:
		return default
