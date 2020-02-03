extends AttackState
"""
State describing first normal attack in character attack chain
"""

func _ready():
	._ready()
	attackbox_timeline = [
		{
			"time": 0.2,
			"enable": true,
			"attackbox": "AttackA1"
		},
		{
			"time": 0.5,
			"enable": false,
			"attackbox": "AttackA1"
		}
	]
	call_deferred("_set_attackboxes")
	
	
func _set_attackboxes():
	self.attackboxes = fsm.attackboxes


func process_state(delta: float):
	.process_state(delta)
	
	
func enter_state(prev_state: String):
	.enter_state(prev_state)
	entity.anim.play("attack_a1")
	fsm.hitboxes.switch_to_area("AttackA1")
	
	
func exit_state(next_state: String):
	.exit_state(next_state)
