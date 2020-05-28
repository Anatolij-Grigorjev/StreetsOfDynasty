extends StateMachine
class_name CharacterStateMachineTemplate
"""
A type of FSM that is suited for cahracters - contains operatable flags
for things like being hurt, moved, caught, killed
"""

var hit_react_move: Vector2 = Vector2.ZERO
var post_caught_state = NO_STATE

var should_die = false
var got_hit: bool = false
var got_caught: bool = false
var next_hit_react_state: String = NO_STATE




func set_post_caught_state(post_caught_state: String):
	self.post_caught_state = post_caught_state
