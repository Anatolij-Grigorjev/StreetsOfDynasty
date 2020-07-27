extends CharacterStateMachineTemplate
"""
Yu main state machine
"""
const MAX_CONSECUTIVE_B2_HITS = 5


var pressed_attack_input: SingleReadVar = SingleReadVar.new(C.AttackInputType.NONE)
var has_caught := SingleReadVar.new(false)
var caught_character: CharacterTemplate = null

var consecutive_b2_hits : int = 0


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
	var was_hit = got_hit.read_and_reset()
	if (Debug.get_debug2_pressed()):
		return "CatchAttack"
	
	match(state):
		"Idle":
			if (was_hit):
				return "HurtLow"
			if (move_direction != Vector2.ZERO):
				return "Walk"
			if (attack_input == C.AttackInputType.NORMAL):
				return "AttackA1"
			return NO_STATE
		"Walk":
			if (was_hit):
				return "HurtLow"
			if (move_direction == Vector2.ZERO):
				return "Idle"
			if (attack_input == C.AttackInputType.NORMAL):
				return "AttackA1"
			return NO_STATE
		"AttackA1":
			if (was_hit):
				return "HurtLow"
			var attack_state = state_nodes[state] as FiniteState
			_cache_next_attack_input(attack_input, attack_state)
			if (not attack_state.can_change_state):
				return NO_STATE
			var next_attack_input = pressed_attack_input.read_and_reset()
			if (next_attack_input == C.AttackInputType.SPECIAL):
				_start_special_flash()
				return "AttackB1"
			if (next_attack_input == C.AttackInputType.NORMAL):
				return "AttackA2"
			if (move_direction != Vector2.ZERO):
				return "Walk"
			if (attack_state.is_state_over):
				return _next_or_default(attack_state)
			return NO_STATE
		"AttackB1":
			if (was_hit):
				return "HurtLow"
			var attack_state = state_nodes[state] as FiniteState
			if (not attack_state.can_change_state):
				return NO_STATE
			#state will change, unset rig position
			entity.rig_custom_position = false
			if (move_direction != Vector2.ZERO):
				return "Walk"
			if (attack_state.is_state_over):
				return _next_or_default(attack_state)
			return NO_STATE
		"AttackA2":
			if (was_hit):
				return "HurtLow"
			var attack_state = state_nodes[state] as FiniteState
			_cache_next_attack_input(attack_input, attack_state)
			if (not attack_state.can_change_state):
				return NO_STATE
			var next_attack_input = pressed_attack_input.read_and_reset()
			if (next_attack_input == C.AttackInputType.SPECIAL):
				consecutive_b2_hits = 1
				_start_special_flash()
				return "AttackB2"
			if (next_attack_input == C.AttackInputType.NORMAL):
				return "CatchAttack"
			if (move_direction != Vector2.ZERO):
				return "Walk"
			if (attack_state.is_state_over):
				return _next_or_default(attack_state)
			return NO_STATE
		"AttackB2":
			if (was_hit):
				consecutive_b2_hits = 0
				return "HurtLow"
			var attack_state = state_nodes[state] as FiniteState
			_cache_next_attack_input(attack_input, attack_state)
			if (not attack_state.can_change_state):
				return NO_STATE
			var next_attack_input = pressed_attack_input.read_and_reset()
			if (next_attack_input == C.AttackInputType.SPECIAL
				and consecutive_b2_hits < MAX_CONSECUTIVE_B2_HITS):
				consecutive_b2_hits += 1
				return "AttackB2"
			if (attack_state.is_state_over):
				consecutive_b2_hits = 0
				return _next_or_default(attack_state)
			return NO_STATE
		"AttackB2F":
			if (was_hit):
				return "HurtLow"
			var attack_state = state_nodes[state] as FiniteState
			if (not attack_state.can_change_state):
				return NO_STATE
			if (move_direction != Vector2.ZERO):
				return "Walk"
			if (attack_state.is_state_over):
				return _next_or_default(attack_state)
			return NO_STATE
		"CatchAttack":
			if (was_hit):
				return "HurtLow"
			var catching_state = state_nodes[state] as FiniteState
			if (not catching_state.can_change_state):
				return NO_STATE
			if (has_caught.read_and_reset()):
				return "CaughtAttack1"
			if (move_direction != Vector2.ZERO):
				return "Walk"
			if (catching_state.is_state_over):
				return _next_or_default(catching_state)
			return NO_STATE
		"CaughtAttack1":
			if (was_hit):
				_release_caught_character()
				return "HurtLow"
			var attack_state = state_nodes[state] as FiniteState
			if (not attack_state.can_change_state):
				return NO_STATE
			_release_caught_character()
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
	if (Input.is_action_just_pressed("attack_special")):
		return C.AttackInputType.SPECIAL
	return C.AttackInputType.NONE
			
			
func _cache_next_attack_input(attack_input: int, attack_state: FiniteState):
	var attack_phase_aspect = attack_state.get_node('AttackStatePhaseAspect')
	if (not attack_phase_aspect):
		print(state, " requires a AttackStatePhaseAspect child!")
		breakpoint
	if (
		attack_phase_aspect.attack_phase != C.AttackPhase.WIND_UP
		and attack_input != C.AttackInputType.NONE
	):
		pressed_attack_input.current_value = attack_input


func _start_special_flash():
	var flasher = $SpriteColorFlashRequestor
	flasher.request_color_flash(Color.blue, 0.2, 0.8, 0.5)


func _on_Catchbox_caught(caught_hitbox: Hitbox):
	var caught_character = Utils.get_areagroup_area_owner(caught_hitbox) as CharacterTemplate
	if (not is_instance_valid(caught_character)):
		return 
	has_caught.current_value = true
	caught_character.emit_signal("got_caught", entity)
	self.caught_character = caught_character
	
	
func _on_character_got_hit(hit_connect: HitConnect):
	got_hit.current_value = true
	
	
func _release_caught_character():
	if (
		is_instance_valid(self.caught_character)
		and _is_character_caught(self.caught_character)
	):
		self.caught_character.emit_signal("got_released")
		

func _is_character_caught(character: CharacterTemplate) -> bool:
	var fsm = character.fsm
	return fsm.state == "Caught"


func _next_or_default(state: FiniteState, default: String = "Idle") -> String:
	if (state.next_state):
		return state.next_state
	else:
		return default
		

