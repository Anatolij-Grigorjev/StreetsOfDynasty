extends StateMachine
class_name CharacterStateMachineTemplate
"""
A type of FSM that is suited for cahracters - contains operatable flags
for things like being hurt, moved, caught, killed
"""

var hurt_move: Vector2 = Vector2.ZERO
var post_caught_state = NO_STATE

var is_hurt_state = false
var is_fall_state = false
var should_die = false





func set_post_caught_state(post_caught_state: String):
	self.post_caught_state = post_caught_state
