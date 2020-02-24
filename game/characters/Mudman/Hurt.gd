extends HurtState
"""
State for getting hurt standing in the belly
"""


func _ready():
	set_hitboxes_timeline([
		{
			"time": 0.0,
			"enable": true,
			"area": "Hurt1"
		},
		{
			"time": 0.1,
			"enable": false,
			"area": "Hurt1"
		},
		{
			"time": 0.1,
			"enable": true,
			"area": "Hurt2"
		},
		{
			"time": 0.6,
			"enable": false,
			"area": "Hurt2"
		}
	])


func process_state(delta: float):
	.process_state(delta)
	
	
func enter_state(prev_state: String):
	.enter_state(prev_state)
	entity.anim.play("hurt")
	
	
func exit_state(next_state: String):
	.exit_state(next_state)
