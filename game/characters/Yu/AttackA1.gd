extends AttackState
"""
State describing first normal attack in character attack chain
"""

func _ready():
	group_id = "A1"
	set_group_timeline([
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
	])


func process_state(delta: float):
	.process_state(delta)
	
	
func enter_state(prev_state: String):
	.enter_state(prev_state)
	_move_with_attack(25, 0.25)
	entity.anim.play("attack_a1")
	fsm.hitboxes.switch_to_area("AttackA1")
	#disable attack areas before chosing one to enable
	fsm.attackboxes.disable_all_areas()
	
	
func exit_state(next_state: String):
	.exit_state(next_state)
	
	
func _move_with_attack(move_distance: float, move_duration: float):
	if ($AttackMove.is_active()):
		return
	$AttackMove.interpolate_method(
		entity, 'do_movement', 
		Vector2.ZERO, Vector2(move_distance, 0), move_duration, 
		Tween.TRANS_EXPO, Tween.EASE_OUT
	)
	entity.LOG.info("move {} -> {}, over {}s", 
		[
			entity.global_position.x, 
			entity.global_position.x + move_distance, 
			move_duration
		]
	)
	$AttackMove.start()
