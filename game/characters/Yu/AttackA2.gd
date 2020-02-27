extends AttackMoveState
"""
State describing second normal attack in character attack chain
"""

func _ready():
	set_attackbox_timeline([
		{
			"time": 0.3,
			"enable": true,
			"area": "AttackA2"
		},
		{
			"time": 0.6,
			"enable": false,
			"area": "AttackA2"
		}
	])
	set_hitboxes_timeline([
		{
			"time": 0.0,
			"enable": true,
			"area": "AttackA2_1"
		},
		{
			"time": 0.3,
			"enable": false,
			"area": "AttackA2_1"
		},
		{
			"time": 0.3,
			"enable": true,
			"area": "AttackA2_2"
		},
		{
			"time": 0.8,
			"enable": false,
			"area": "AttackA2_2"
		},
		{
			"time": 0.8,
			"enable": true,
			"area": "AttackA2_1"
		}
	])


func process_state(delta: float):
	.process_state(delta)
	
	
func enter_state(prev_state: String):
	.enter_state(prev_state)
	_move_with_attack(Vector2(35, -4), 0.2)
	entity.anim.play("attack_a2")
	
	fsm.attackboxes.disable_all_areas()
	fsm.hitboxes.disable_all_areas()
	
	
func exit_state(next_state: String):
	.exit_state(next_state)
