extends Node
class_name PerpetualState
"""
Type of state that goes on until an external trigger forces a change
Properties loaded from a property source
"""
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
# type is StateMachine, not explicit due to cyclic type loading
var fsm
#root node of the character these states manipulate, owner of FSM
var entity: Node


func _ready():
	set_process(false)
	set_physics_process(false)


func process_state(delta: float):
	if (is_instance_valid(hitbox_areas_timeline)):
		hitbox_areas_timeline.process_timeline(hitbox_group_id, delta)
	if (is_instance_valid(attackbox_areas_timeline)):
		attackbox_areas_timeline.process_timeline(attackbox_group_id, delta)
	for attackbox in fsm.attackboxes.get_enabled_areas():
		attackbox.process_attack()
	
	
func enter_state(prev_state: String):
	if (is_instance_valid(hitbox_areas_timeline)):
		hitbox_areas_timeline.reset(hitbox_group_id)
	if (is_instance_valid(attackbox_areas_timeline)):
		attackbox_areas_timeline.reset(attackbox_group_id)
	
	
	
func exit_state(next_state: String):
	pass 
	

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
