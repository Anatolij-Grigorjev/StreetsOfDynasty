extends StateMachine


onready var hitboxes: AreaGroup = get_node(@"../Body/HitboxGroup")
onready var attackboxes: AreaGroup = get_node(@"../Body/AttackboxGroup")


var target: Node2D


func _ready():
	._ready()
	call_deferred("set_state", "Idle")
	if (get_tree().get_nodes_in_group("Player")):
		var player = get_tree().get_nodes_in_group("Player")[0]
		call_deferred("_set_target", player)
		
func set_state(next_state: String):
	.set_state(next_state)
	if (is_instance_valid($Logger)):
		$Logger.info("'{}' -> '{}'", [previous_state, next_state])
	

func _set_target(new_target: Node2D):
	self.target = new_target
	
	
func _get_next_state(delta: float) -> String:
	
	var move_direction = _get_move_direction() if target else Vector2.ZERO
	var hurting: bool = entity.is_hurting
	match(state):
		"Idle":
			if (hurting):
				return "Hurt"
			if (move_direction != Vector2.ZERO):
				return "Walk"
			return NO_STATE
		"Walk":
			if (hurting):
				return "Hurt"
			if (move_direction == Vector2.ZERO):
				return "Idle"
			var should_keep_moving = true
			if (should_keep_moving):
				return NO_STATE
			else:
				return "WaitIdle"
		"Hurt":
			var state_node = state_nodes[state]
			if (state_node.is_hurting):
				return NO_STATE
			return "Idle"
		"WaitIdle":
			var state_node = state_nodes[state] as WaitState
			if (hurting):
				return "Hurt"
			if (state_node.waiting_over):
				return state_node.next_state
			else:
				return NO_STATE
		_:
			breakpoint
			return NO_STATE


func _get_move_direction() -> Vector2:
	if (is_instance_valid(target)):
		return entity.global_position.direction_to(target.global_position)
	else:
		return Vector2.ZERO
	
