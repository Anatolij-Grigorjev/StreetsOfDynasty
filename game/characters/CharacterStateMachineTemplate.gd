extends StateMachine
class_name CharacterStateMachineTemplate
"""
A type of FSM that is suited for cahracters - contains operatable flags
for things like being hurt, moved, caught, killed
"""

var hit_react_move := SingleReadVar.new(Vector2.ZERO)
var next_hit_react_state := SingleReadVar.new(NO_STATE)

var got_killed := SingleReadVar.new(false)
var got_hit := SingleReadVar.new(false)
var got_caught := SingleReadVar.new(false)
var got_released := SingleReadVar.new(false)
