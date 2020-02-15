extends AttackState
"""
State describing first normal attack in character attack chain
"""

func _ready():
	areas_timeline_name = "AttackA1Timeline"
	areas_timeline_items = [
		{
			"time": 0.2,
			"enable": true,
			"area": "AttackA1"
		},
		{
			"time": 0.5,
			"enable": false,
			"area": "AttackA1"
		}
	]


func process_state(delta: float):
	.process_state(delta)
	
	
func enter_state(prev_state: String):
	.enter_state(prev_state)
	entity.anim.play("attack_a1")
	fsm.hitboxes.switch_to_area("AttackA1")
	#disable attack areas before chosing one to enable
	fsm.attackboxes.disable_all_areas()
	
	
func exit_state(next_state: String):
	.exit_state(next_state)
