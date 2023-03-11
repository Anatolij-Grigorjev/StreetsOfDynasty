extends PerpetualState
"""
Walking state version specific to Yu.
Allows enabling enemy catching when walking starts and disabling 
when walking is done
"""

func enter_state(prev_state: String):
	.enter_state(prev_state)
	entity.enemy_catcher.enabled = true
	
	
func exit_state(next_state: String):
	.exit_state(next_state)
	entity.enemy_catcher.enabled = false
