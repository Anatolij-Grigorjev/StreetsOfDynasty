extends StateMachine


onready var hitboxes: AreaGroup = get_node(@"../Body/HitboxGroup")
onready var attackboxes: AreaGroup = get_node(@"../Body/AttackboxGroup")


var target: Node2D

var hurt_move: Vector2 = Vector2.ZERO

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
	
	var move_direction = Vector2.ZERO#_get_move_direction() if target else Vector2.ZERO
	var hurting: bool = entity.is_hurting
	
	#apply hurt move
	if (hurting and hurt_move != Vector2.ZERO):
		var hurt_state_node = state_nodes["Hurt"]
		var moved_aspect = hurt_state_node.get_node('MovedStateAspect')
		if (moved_aspect):
			moved_aspect.move_impulse = hurt_move
		hurt_move = Vector2.ZERO
		
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
			var hurt_state = state_nodes[state] as FiniteState
			if (not hurt_state.is_state_over):
				return NO_STATE
			return hurt_state.next_state
		"Dying":
			var dying_state = state_nodes[state] as FiniteState
			if (not dying_state.is_state_over):
				return NO_STATE
			#after state animation is over we need to 
			#provide following state
			#because the dying aspect engages on state exit
			#state exit only happens if there is a following state
			return "Dying"
		_:
			breakpoint
			return NO_STATE


func _get_move_direction() -> Vector2:
	if (is_instance_valid(target)):
		return entity.global_position.direction_to(target.global_position)
	else:
		return Vector2.ZERO
		
		
func _on_character_damage_received(damage: float, health: float, total_healt: float):
	if (health <= 0.0):
		state_nodes["Hurt"].next_state = "Dying"
	
