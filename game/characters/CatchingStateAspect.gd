extends State
class_name CatchingStateAspect
"""
This aspect uses a target CharacterTemplate which is caught by 
owner of this aspect
"""
var caught_character: CharacterTemplate



func process_state(delta: float):
	.process_state(delta)
	
	
func enter_state(prev_state: String):
	.enter_state(prev_state)
	caught_character.is_caught = true
	#TODO: setup caught and catcher positions
	#transition caught to caught state
	
	
func exit_state(next_state: String):
	.exit_state(next_state)
	caught_character.is_caught = false
