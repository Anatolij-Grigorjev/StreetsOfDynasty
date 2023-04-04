extends FiniteState
"""
Dying extension for mudman to prevent playing full dying animation if 
character already lying down
"""

func enter_state(prev_state: String):
	.enter_state(prev_state)
	if (prev_state == "Falling"):
		#skip animation
		var anim = entity.anim
		anim.stop()
		anim.current_animation = self.state_animation
		anim.advance(0.4)
		anim.play()
