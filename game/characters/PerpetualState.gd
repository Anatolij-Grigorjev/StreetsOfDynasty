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
#preserve velocity from previous state
export(bool) var keep_velocity: bool = false


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
	for attackbox in entity.attackboxes.get_enabled_areas():
		attackbox.process_attack()
	
	
func enter_state(prev_state: String):
	.enter_state(prev_state)
	if (is_instance_valid(hitbox_areas_timeline)):
		hitbox_areas_timeline.reset(hitbox_group_id)
	if (is_instance_valid(attackbox_areas_timeline)):
		attackbox_areas_timeline.reset(attackbox_group_id)
	
	if (not keep_velocity):
		entity.velocity = Vector2()
	
	entity.attackboxes.disable_all_areas()
	entity.hitboxes.disable_all_areas()
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
	move_delay: float = 0.0,
	move_type: int = C.CharacterMoveType.MOVE_SLIDE
):
	#with MOVE_SLIDE value is divided by delta in physics engine
	#so to ensure amount travelled we need to divide by time again
	var time_divisor := (move_duration 
		if move_type == C.CharacterMoveType.MOVE_SLIDE 
		else 1.0
	)
	var facing_aware_move_impulse := Vector2(
		abs(move_impulse.x) * entity.facing, 
		move_impulse.y
	) / time_divisor
	var move_method := _get_move_method(move_type)
	entity.call(move_method, facing_aware_move_impulse)
	Debug.LOG.info("%s.%s(%s) for %ss", [entity, move_method, facing_aware_move_impulse, move_duration])
	yield(get_tree().create_timer(move_duration), "timeout")
	entity.call(move_method, Vector2.ZERO)
	
		
		
func _get_move_method(move_type: int) -> String:
	match(move_type):
		C.CharacterMoveType.MOVE_SLIDE:
			return 'do_movement_slide'
		C.CharacterMoveType.MOVE_COLLIDE:
			return 'do_movement_collide'
		_:
			print("Unknown movement type constant: %s" % move_type)
			breakpoint
	return ""


		
func _set_move_impulse(state_params: Dictionary):
	if (state_params.has("state_move_tiles")):
		var state_move_tiles: Dictionary = state_params.state_move_tiles as Dictionary
		assert(state_move_tiles != null)
		state_params.state_move_impulse = _build_entity_move_impulse(state_move_tiles)
		state_params.state_move_duration = Utils.get_or_default(state_move_tiles, "duration", 0.2)
		
		
func _build_entity_move_impulse(state_move_tiles: Dictionary) -> Vector2:
	var move_in_tiles := Utils.dict2vector(state_move_tiles)
	return Vector2(
		move_in_tiles.x * owner.move_speed.x,
		move_in_tiles.y * owner.move_speed.y
	)


func _set_areagroup_timelines(state_params: Dictionary):
	if (state_params.has('hitboxes_timeline')):
		hitbox_group_id = name
		set_hitboxes_timeline(state_params.hitboxes_timeline)
	if (state_params.has('attackboxes_timeline')):
		attackbox_group_id = name
		set_attackboxes_timeline(state_params.attackboxes_timeline)
