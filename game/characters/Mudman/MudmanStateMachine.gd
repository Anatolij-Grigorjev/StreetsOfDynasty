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
	Debug.log_info("{}: '{}' -> '{}'", [owner, previous_state, next_state])
	

func _set_target(new_target: Node2D):
	self.target = new_target
	
	
func _get_next_state(delta: float) -> String:
	
	var move_direction = Vector2.ZERO
	
	var was_hit = got_hit.read_and_reset()
	var was_caught = got_caught.read_and_reset()
	var was_released = got_released.read_and_reset()
	
	var hit_react_state = NO_STATE
	if (was_hit):
		hit_react_state = next_hit_react_state.read_and_reset()
		_apply_hit_react_move(
			hit_react_move.read_and_reset(), 
			hit_react_state
		)
		
	var next_state = _check_got_killed()
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
			if (was_hit):
				return hit_react_state
			if (was_released):
				var state_node: PerpetualState = state_nodes[state]
				return "Falling"
			
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
		"Fallen":
			var fallen_state = get_state(state) as FiniteState
			if (not fallen_state.is_state_over):
				return NO_STATE
			return fallen_state.next_state
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
		got_killed.current_value = true
		
		
func _on_character_reduce_stability(prev: float, current: float, total: float):
	next_hit_react_state.current_value = _build_next_hit_receive_state(current)
	

func _on_character_got_hit(hit_connect: HitConnect):
	got_hit.current_value = true
	
	
func _on_character_got_caught(catcher: CharacterTemplate):
	got_caught.current_value = true
	if (_can_be_caught_in_state(state)):
		_prepare_look_caught(catcher)


func _prepare_look_caught(catcher: CharacterTemplate):
	var caught: CharacterTemplate = entity as CharacterTemplate
	caught.facing = -catcher.facing
	var distance = (caught.caught_point.global_position - catcher.catch_point.global_position)
	catcher.global_position += Vector2(distance.x, 0.0)
	
	
	
func _on_character_got_released():
	got_released.current_value = true
	

func _on_character_hit_displaced(displacement: Vector2):
	hit_react_move.current_value = displacement


func _build_next_hit_receive_state(stability: float) -> String:
	if (stability > 90):
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
			moved_aspect.set_move_impulses(hit_react_move)
	
	
func _check_got_killed():
	if (_can_move_to_dying_state(state) 
		and got_killed.read_and_reset()):
		#should transition to dying
		return "Dying"
	#not dying yet
	return NO_STATE


func _can_move_to_dying_state(state: String) -> bool:
	#only die if not held caught or already dying
	return state != "Dying" and state != "Caught"
	

func _can_be_caught_in_state(state: String) -> bool:
	return not ["Falling", "Fallen", "Dying", "Caught"].has(state)
