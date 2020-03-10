extends State
class_name PerpetualState
"""
Type of state that goes on until an external trigger forces a change
Properties loaded from a property source
State can be a composite for substates or state aspects that supply their
own State-like lifecycles
"""
#path to json file with object that represents state data
export(String) var state_params_filepath
#reference to the hitbox groups timeline to animate hitbox groups
export(NodePath) var hitbox_areas_timeline_path
#reference to the attack groups timeline to animate attack groups
export(NodePath) var attackbox_areas_timeline_path
#path to tween node to help character movement during state
export(NodePath) var tween_path


#reference to the areas timeline if valid path provided
onready var hitbox_areas_timeline: AreaGroupTimeline = get_node(hitbox_areas_timeline_path)
#reference to the areas timeline if valid path provided
onready var attackbox_areas_timeline: AreaGroupTimeline = get_node(attackbox_areas_timeline_path)
onready var tween: Tween = get_node(tween_path)


#group id for timeline processing
var attackbox_group_id: String = ""
#group id for timeline processing
var hitbox_group_id: String = ""

#state params map, generated from file JSON
#this contains properties like:
# state_animation
# state_move_impulse
# state_move_duration
var state_params: Dictionary = {
	'state_animation': "",
	'state_move_impulse': Vector2.ZERO,
	'state_move_duration': 0.2
}


func _ready():
	#parent disables physics
	assert(state_params_filepath != null)
	var loaded_state_params = Utils.get_json_from_file(state_params_filepath) as Dictionary
	state_params = Utils.merge_dicts(state_params, loaded_state_params)
	_set_move_impulse(state_params)
	_set_areagroup_timelines(state_params)
	

func process_state(delta: float):
	.process_state(delta)
	if (is_instance_valid(hitbox_areas_timeline)):
		hitbox_areas_timeline.process_timeline(hitbox_group_id, delta)
	if (is_instance_valid(attackbox_areas_timeline)):
		attackbox_areas_timeline.process_timeline(attackbox_group_id, delta)
	for attackbox in fsm.attackboxes.get_enabled_areas():
		attackbox.process_attack()
	
	
func enter_state(prev_state: String):
	.enter_state(prev_state)
	if (is_instance_valid(hitbox_areas_timeline)):
		hitbox_areas_timeline.reset(hitbox_group_id)
	if (is_instance_valid(attackbox_areas_timeline)):
		attackbox_areas_timeline.reset(attackbox_group_id)
	
	fsm.attackboxes.disable_all_areas()
	fsm.hitboxes.disable_all_areas()
	if (state_params.state_move_impulse != Vector2.ZERO):
		_move_with_state(
			state_params.state_move_impulse, 
			state_params.state_move_duration
		)
	if (state_params.state_animation != ""):
		entity.anim.play(state_params.state_animation)
	
	
func exit_state(next_state: String):
	.exit_state(next_state)
	

func set_hitboxes_timeline(timeline_items: Array):
	assert(is_instance_valid(hitbox_areas_timeline))
	hitbox_areas_timeline.add_group_timeline(hitbox_group_id, timeline_items)
	

func set_attackboxes_timeline(timeline_items: Array):
	assert(is_instance_valid(attackbox_areas_timeline))
	attackbox_areas_timeline.add_group_timeline(attackbox_group_id, timeline_items)
	

func _move_with_state(
	move_impulse: Vector2, 
	move_duration: float, 
	move_delay: float = 0.0
):
	var facing_aware_move_impulse := Vector2(
		move_impulse.x * entity.facing, move_impulse.y
	)
	tween.interpolate_method(
		entity, 'do_movement_slide', 
		Vector2.ZERO, facing_aware_move_impulse, move_duration, 
		Tween.TRANS_EXPO, Tween.EASE_OUT, 
		move_delay
	)
	entity.LOG.info("move {} -> {}, over {}s", 
		[
			entity.global_position, 
			entity.global_position + facing_aware_move_impulse, 
			move_duration
		]
	)
	if (not tween.is_active()):
		tween.start()
		
		
func _set_move_impulse(state_params: Dictionary):
	if (state_params.has("state_move")):
		var state_move: Dictionary = state_params.state_move as Dictionary
		assert(state_move != null)
		state_params.state_move_impulse = Utils.dict2vector(state_move)
		state_params.state_move_duration = Utils.get_or_default(state_move, "duration", 0.2)
		
		
func _set_areagroup_timelines(state_params: Dictionary):
	if (state_params.has('hitboxes_timeline')):
		hitbox_group_id = name
		set_hitboxes_timeline(state_params.hitboxes_timeline)
	if (state_params.has('attackboxes_timeline')):
		attackbox_group_id = name
		set_attackboxes_timeline(state_params.attackboxes_timeline)
