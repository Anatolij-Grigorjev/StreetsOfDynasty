extends AttackMoveState
"""
A template version of a character attack state that involves movement
"""
export(String) var attack_params_file: String


var attack_params: Dictionary = {}
var attack_move_impulse: Vector2 = Vector2.ZERO
var attack_animation: String


func _ready():
	assert(attack_params_file != null)
	attack_params = Utils.get_json_from_file(attack_params_file) as Dictionary
	assert(attack_params != null)
	_set_move_impulse(attack_params)
	_set_areagroup_timelines(attack_params)
	_set_attack_animation(attack_params)


func process_state(delta: float):
	.process_state(delta)
	
	
func enter_state(prev_state: String):
	.enter_state(prev_state)
	fsm.attackboxes.disable_all_areas()
	fsm.hitboxes.disable_all_areas()
	if (attack_move_impulse != Vector2.ZERO):
		_move_with_attack(attack_move_impulse, 0.2)
	entity.anim.play(attack_animation)
	
	
	
func exit_state(next_state: String):
	.exit_state(next_state)
	
	
func _set_move_impulse(attack_params: Dictionary):
	if (attack_params.has("attack_move")):
		var attack_move: Dictionary = attack_params.attack_move as Dictionary
		assert(attack_move != null)
		attack_move_impulse = Vector2(attack_move.x, attack_move.y)
		
		
func _set_attack_animation(attack_params: Dictionary):
	assert(attack_params.has("attack_animation"))
	attack_animation = attack_params.attack_animation as String
		
		
func _set_areagroup_timelines(attack_params: Dictionary):
	assert(attack_params.hitboxes_timeline as Array != null)
	hitbox_group_id = name
	set_hitboxes_timeline(attack_params.hitboxes_timeline)
	assert(attack_params.attackboxes_timeline as Array != null)
	attackbox_group_id = name
	set_attackboxes_timeline(attack_params.attackboxes_timeline)
