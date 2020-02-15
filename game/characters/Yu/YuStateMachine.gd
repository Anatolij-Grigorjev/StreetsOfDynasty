extends StateMachine

enum AttackInput {
	NONE = 0,
	NORMAL = 1,
	SPECIAL = 2
}

onready var hitboxes: AreaGroup = get_node(@"../Body/HitboxGroup")
onready var attackboxes: AreaGroup = get_node(@"../Body/AttackboxGroup")
onready var current_state_lbl: Label = get_node(@"../CurrentState")


func _ready():
	._ready()
	call_deferred("set_state", "Idle")


func set_state(next_state: String) -> void:
	.set_state(next_state)
	#setter might get called before node init
	if (is_instance_valid(current_state_lbl)):
		current_state_lbl.text = state
	
	
func _get_next_state(delta: float) -> String:
	var move_direction = _get_move_direction()
	var attack_input: int = _get_attack_input()
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
			var attack_state: AttackState = state_nodes[state] as AttackState
			if (not attack_state.can_change_attack):
				return NO_STATE
			if (move_direction != Vector2.ZERO):
				return "Walk"
			if (attack_state.is_attack_over):
				return "Idle"
			return NO_STATE
		"HurtLow":
			var state_node = state_nodes[state]
			if (state_node.is_hurting):
				return NO_STATE
			return "Idle"
		_:
			breakpoint
			return NO_STATE


func _get_move_direction() -> Vector2:
	var move_direction_horiz = -int(Input.is_action_pressed("move_left")) + int(Input.is_action_pressed("move_right"))
	var move_direction_vert = -int(Input.is_action_pressed("move_up")) + int(Input.is_action_pressed("move_down"))
	
	return Vector2(move_direction_horiz, move_direction_vert).normalized()
	
	
func _get_attack_input() -> int:
	if (Input.is_action_pressed("attack_normal")):
		return AttackInput.NORMAL
	return AttackInput.NONE
