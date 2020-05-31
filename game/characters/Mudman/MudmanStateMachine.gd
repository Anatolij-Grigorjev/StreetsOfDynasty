extends CharacterStateMachineTemplate

var target: Node2D


func _ready():
	._ready()
	call_deferred("set_state", "Idle")
	if (get_tree().get_nodes_in_group("Player")):
		var player = get_tree().get_nodes_in_group("Player")[0]
		call_deferred("_set_target", player)
		
		
func set_state(next_state: String):
	.set_state(next_state)
	Debug.log_info("'{}' -> '{}'", [previous_state, next_state])
	

func _set_target(new_target: Node2D):
	self.target = new_target
	
	
func _get_next_state(delta: float) -> String:
	
	var move_direction = Vector2.ZERO
	
	var was_hit = got_hit
	var was_caught = got_caught
	
	var hit_react_state = NO_STATE
	if (was_hit):
		hit_react_state = next_hit_react_state
		next_hit_react_state = NO_STATE
		
		_apply_hit_react_move(hit_react_move, hit_react_state)
		hit_react_move = Vector2.ZERO
		
		got_hit = false
		
	var next_state = _check_should_die()
	if (next_state != NO_STATE):
		return next_state
	
	match(state):
		"Idle":
			if (was_hit):
				return hit_react_state
			if(was_caught):
				return "Caught"
			if (move_direction != Vector2.ZERO):
				return "Walk"
			return NO_STATE
		"Walk":
			if (was_hit):
				return hit_react_state
			if(was_caught):
				return "Caught"
			if (move_direction == Vector2.ZERO):
				return "Idle"
			var should_keep_moving = true
			if (should_keep_moving):
				return NO_STATE
			else:
				return "WaitIdle"
		"Caught":
			if (not was_caught):
				return post_caught_state
			
			return NO_STATE
		"Hurt":
			#reset hurting if hit again
			if (was_hit):
				return hit_react_state
			#possible to be caught while hurting
			if (was_caught):
				return "Caught"
			var hurt_state = get_state(state) as FiniteState
			if (not hurt_state.is_state_over):
				return NO_STATE
			return hurt_state.next_state
		"Falling":
			var fall_state = get_state(state) as FiniteState
			if (not fall_state.is_state_over):
				return NO_STATE
			return fall_state.next_state
		"Dying":
			var dying_state = get_state(state) as FiniteState
			if (not dying_state.is_state_over):
				return NO_STATE
			#DyingStateAspect triggers on state exit
			#state exit only happens if there is a following state
			return "Dying"
		_:
			breakpoint
			return NO_STATE
		
		
func _on_character_damage_received(damage: float, health: float, total_healt: float):
	if (health <= 0.0):
		should_die = true
		
		
func _on_character_reduce_stability(prev: float, current: float, total: float):
	next_hit_react_state = _build_next_hit_receive_state(current)
	

func _on_character_got_hit(hit_connect: HitConnect):
	got_hit = true
	
	
func _on_character_got_caught(catcher: CharacterTemplate):
	got_caught = true
	

func _on_character_hit_displaced(displacement: Vector2):
	hit_react_move = displacement


func _build_next_hit_receive_state(stability: float) -> String:
	if (stability > 50):
		return NO_STATE
	elif (stability > 0):
		return "Hurt"
	else:
		return "Falling"
	
	
func _apply_hit_react_move(hit_react_move: Vector2, hit_react_state: String):
	if (hit_react_move and hit_react_state != NO_STATE):
		var hurt_state_node = state_nodes[hit_react_state]
		var moved_aspect = hurt_state_node.get_node('MovedStateAspect')
		if (moved_aspect):
			moved_aspect.move_impulse = hit_react_move
	
	
func _check_should_die():
	if (should_die):
		if (_can_move_to_dying_state(state)):
			should_die = false
			#should transition to dying
			return "Dying"
	#not dying yet
	return NO_STATE


func _can_move_to_dying_state(state: String) -> bool:
	#only die if not held caught or already dying
	return state != "Dying" and state != "Caught"
