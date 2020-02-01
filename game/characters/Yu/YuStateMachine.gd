extends StateMachine

onready var hitboxes: AreaGroup = get_node(@"../Body/HitboxGroup")
onready var attackboxes: AreaGroup = get_node(@"../Body/AttackboxGroup")


func _ready():
	._ready()
	call_deferred("set_state", "Idle")
	
	
func _get_next_state(delta: float) -> String:
	var move_direction = _get_move_direction()
	match(state):
		"Idle":
			if (move_direction != Vector2.ZERO):
				return "Walk"
			return NO_STATE
		"Walk":
			if (move_direction == Vector2.ZERO):
				return "Idle"
			return NO_STATE
		"AttackA1":
			var attack_state: AttackState = state_nodes[state] as AttackState
			if (not attack_state.can_change_attack):
				return NO_STATE
			if (move_direction != Vector2.ZERO):
				return "Walk"
			if (attack_state.attack_over):
				return "Idle"
			return NO_STATE
		_:
			breakpoint
			return NO_STATE


func _get_move_direction() -> Vector2:
	var move_direction_horiz = -int(Input.is_action_pressed("move_left")) + int(Input.is_action_pressed("move_right"))
	var move_direction_vert = -int(Input.is_action_pressed("move_up")) + int(Input.is_action_pressed("move_down"))
	
	return Vector2(move_direction_horiz, move_direction_vert).normalized()
