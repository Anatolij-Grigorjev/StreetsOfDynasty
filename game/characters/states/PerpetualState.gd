extends State
class_name PerpetualState
"""
Type of state that goes on until an external trigger forces a change
Properties loaded from a property source
State can be a composite for substates or state aspects that supply their
own State-like lifecycles
"""
signal state_animation_finished(anim_name)


#animation to be played during state
export(String) var state_animation
#preserve velocity from previous state
export(bool) var keep_velocity: bool = false

#next state character transitions into if this state ends
export(String) var next_state: String = StateMachine.NO_STATE


func _ready():
	call_deferred("_setup_animation_finished_signal")
	

func process_state(delta: float):
	.process_state(delta)
	for attackbox in entity.attackboxes.get_enabled_areas():
		attackbox.process_attack()
	
	
func enter_state(prev_state: String):
	.enter_state(prev_state)
	if (not keep_velocity):
		entity.velocity = Vector2()

	if (state_animation != ""):
		entity.anim.play(state_animation)
	
	
func exit_state(next_state: String):
	.exit_state(next_state)
	if (state_animation != ""):
		#reset animation in case it needs to replayed
		entity.anim.stop(true)
	

func _move_with_state(
	move_impulse: Vector2, 
	move_duration: float, 
	move_delay: float = 0.0,
	move_type: int = C.CharacterMoveType.MOVE_SLIDE
):
	#with MOVE_SLIDE value is divided by delta in physics engine
	#so to ensure amount travelled we need to divide by time again
	var time_divisor := (move_duration 
		if move_type == C.CharacterMoveType.MOVE_SLIDE 
		else 1.0
	)
	var facing_aware_move_impulse := Vector2(
		abs(move_impulse.x) * entity.facing, 
		move_impulse.y
	) / time_divisor
	var move_method := _get_move_method(move_type)
	entity.call(move_method, facing_aware_move_impulse)
	Debug.log_info("%s.%s(%s) for %ss", [entity, move_method, facing_aware_move_impulse, move_duration])
	yield(get_tree().create_timer(move_duration), "timeout")
	entity.call(move_method, Vector2.ZERO)
	
		
		
func _get_move_method(move_type: int) -> String:
	match(move_type):
		C.CharacterMoveType.MOVE_SLIDE:
			return 'do_movement_slide'
		C.CharacterMoveType.MOVE_COLLIDE:
			return 'do_movement_collide'
		_:
			print("Unknown movement type constant: %s" % move_type)
			breakpoint
	return ""
	
	
func _on_AnimationPlayer_animation_finished(anim_name: String):
	if (anim_name == state_animation):
		emit_signal("state_animation_finished", anim_name)


func _setup_animation_finished_signal():
	entity.anim.connect("animation_finished", self, "_on_AnimationPlayer_animation_finished")
