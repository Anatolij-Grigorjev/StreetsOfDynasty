extends PerpetualState
class_name FiniteState
"""
A type of character state that lasts the duration of its state animation

Can have effective state ranges, counted against animation time
(state commit start/end) during which the state is locked
 and ignores external inputs
"""
#when character starts ignoring external input to chagne state
export(float) var state_commit_anim_sec := 0.0
##when character stops ignoring external input to chagne state
export(float) var state_commit_end_anim_sec := 0.93
#can the state be changed into another state?
#this is 'true' while 'state_time' is out of commit ranges
var can_change_state := true
#is the state over and should transition
var is_state_over := true
#handle on entity animator
var animator: AnimationPlayer


func _init():
	call_deferred("_inject_entity_animator")


func process_state(delta: float):
	.process_state(delta)
	if (not is_state_over):
		_check_can_change_state()
	
	
func _check_can_change_state():
	var state_time = _get_state_animation_time()
	can_change_state = not (
		state_time >= state_commit_anim_sec 
		and state_time <= state_commit_end_anim_sec
	)
		
		
func _finish_state():
	is_state_over = true
	can_change_state = true
	
	
func enter_state(prev_state: String):
	.enter_state(prev_state)
	is_state_over = false
	
	
func _get_state_animation_time() -> float:
	if (animator.current_animation == state_animation):
		return animator.current_animation_position
	else:
		return 0.0
	
	
func _inject_entity_animator():
	animator = entity.anim as AnimationPlayer
	
	
func _on_AnimationPlayer_animation_finished(anim_name: String):
	._on_AnimationPlayer_animation_finished(anim_name)
	if (anim_name == state_animation):
		_finish_state()
