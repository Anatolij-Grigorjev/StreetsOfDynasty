extends StateMachine

enum AttackInput {
	NONE = 0,
	NORMAL = 1,
	SPECIAL = 2
}


signal next_attack_input_changed(next_attack_input)


export(float) var next_attack_input_cache_ttl: float = 0.3


onready var hitboxes: AreaGroup = get_node(@"../Body/HitboxGroup")
onready var attackboxes: AreaGroup = get_node(@"../Body/AttackboxGroup")


var next_attack_input: int = AttackInput.NONE
var current_next_attack_input_ttl: float = 0.0


func _ready():
	call_deferred("set_state", "Idle")
	

func set_state(next_state: String):
	.set_state(next_state)
	if (entity and is_instance_valid(entity.LOG)):
		entity.LOG.info("'{}' -> '{}'", [previous_state, next_state])
		
		
func _process(delta):
	_refresh_next_attack_cache(delta)
	
	
func _get_next_state(delta: float) -> String:
	var move_direction = _get_move_direction()
	var attack_input: int = _get_attack_input()
	_cache_next_attack_input(attack_input)
	var hurting: bool = entity.is_hurting or Input.is_action_pressed("debug1")
	match(state):
		"Idle":
			if (hurting):
				return "HurtLow"
			if (move_direction != Vector2.ZERO):
				return "Walk"
			if (attack_input == AttackInput.NORMAL):
				return "AttackA1"
			return NO_STATE
		"Walk":
			if (hurting):
				return "HurtLow"
			if (move_direction == Vector2.ZERO):
				return "Idle"
			if (attack_input == AttackInput.NORMAL):
				return "AttackA1"
			return NO_STATE
		"AttackA1":
			if (hurting):
				return "HurtLow"
			var attack_state = state_nodes[state] as FiniteState
			if (not attack_state.can_change_state):
				return NO_STATE
			if (move_direction != Vector2.ZERO):
				return "Walk"
			if (next_attack_input == AttackInput.NORMAL):
				return "AttackA2"
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
		return AttackInput.NORMAL
	return AttackInput.NONE
	
	
func _cache_next_attack_input(attack_input: int):
	if (not attack_input == AttackInput.NONE
		and attack_input != next_attack_input):
		next_attack_input = attack_input
		current_next_attack_input_ttl = next_attack_input_cache_ttl
		emit_signal("next_attack_input_changed", next_attack_input)
		

func _refresh_next_attack_cache(delta: float):
	if (current_next_attack_input_ttl > 0.0):
		current_next_attack_input_ttl -= delta
		if (current_next_attack_input_ttl <= 0.0):
			next_attack_input = AttackInput.NONE
			current_next_attack_input_ttl = 0.0
			emit_signal("next_attack_input_changed", AttackInput.NONE)
			

func _next_or_default(state: FiniteState, default: String = "Idle") -> String:
	if (state.next_state):
		return state.next_state
	else:
		return default
