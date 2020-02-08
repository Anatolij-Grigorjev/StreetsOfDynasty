extends HurtState
"""
State for getting hurt standing in the belly
"""


func _ready():
	areas_timeline_name = "HurtLowTimeline"
	areas_timeline_items = [
		{
			"time": 0.0,
			"enable": true,
			"area": "HurtLow1"
		},
		{
			"time": 0.1,
			"enable": false,
			"area": "HurtLow1"
		},
		{
			"time": 0.1,
			"enable": true,
			"area": "HurtLow2"
		},
		{
			"time": 0.2,
			"enable": false,
			"area": "HurtLow2"
		},
		{
			"time": 0.2,
			"enable": true,
			"area": "HurtLow3"
		},
		{
			"time": 0.3,
			"enable": false,
			"area": "HurtLow3"
		},
		{
			"time": 0.3,
			"enable": true,
			"area": "HurtLow4"
		},
		{
			"time": 0.9,
			"enable": false,
			"area": "HurtLow4"
		},
		{
			"time": 0.9,
			"enable": true,
			"area": "HurtLow3"
		},
		{
			"time": 1.1,
			"enable": false,
			"area": "HurtLow3"
		},
		{
			"time": 1.1,
			"enable": true,
			"area": "HurtLow2"
		},
		{
			"time": 1.2,
			"enable": false,
			"area": "HurtLow2"
		}
	]


func process_state(delta: float):
	.process_state(delta)
	
	
func enter_state(prev_state: String):
	.enter_state(prev_state)
	entity.anim.play("hurt_low")
	
	
func exit_state(next_state: String):
	.exit_state(next_state)
