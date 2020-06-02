extends StateMachine
class_name CharacterStateMachineTemplate
"""
A type of FSM that is suited for cahracters - contains operatable flags
for things like being hurt, moved, caught, killed
"""

var hit_react_move: Vector2 = Vector2.ZERO

var got_killed: bool = false
var got_hit: bool = false
var got_caught: bool = false
var got_released: bool = false
var next_hit_react_state: String = NO_STATE
