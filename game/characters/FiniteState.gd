extends PerpetualState
class_name FiniteState
"""
A type of standartized character state that lasts a fixes amount
of time and then moves on to Idle or whichever is configured

Can have effective state ranges (state commit start/end)
during which the state is locked and ignores external inputs
"""
#when character starts ignoring external input to chagne state
export(float) var state_commit_start_sec := 0.0
##when character stops ignoring external input to chagne state
export(float) var state_commit_end_sec := 0.93
#total length of finite state. after this amount elapses character
#forcefully transitions to configured 'next_state' or Idle
export(float) var state_length_sec := 1.0
#next state character transitions into if state length elapsed with no
#external input
export(String) var next_state: String

#current elapsed state time
var state_time: float = 0.0
#can the state be changed into another state?
#this is 'true' while 'state_time' is out of commit ranges
var can_change_state := true
#is the state over and should transition
var is_state_over := true


func process_state(delta: float):
	.process_state(delta)
	if (not is_state_over):
		_check_can_change_state()
		_check_state_finished()
	state_time += delta
	
	
func _check_can_change_state():
	can_change_state = not (
		state_time >= state_commit_start_sec 
		and state_time <= state_commit_end_sec
	)
	
	
func _check_state_finished():
	if (not is_state_over and state_time >= state_length_sec):
		_finish_state()
		
		
func _finish_state():
	is_state_over = true
	can_change_state = true
	
	
func enter_state(prev_state: String):
	.enter_state(prev_state)
	state_time = 0.0
	is_state_over = false
