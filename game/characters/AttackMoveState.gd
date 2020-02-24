extends AttackState
class_name AttackMoveState
"""
Attack state subtrait that includes operation with a dedicated tween
"""
export(NodePath) var tween_path

onready var tween: Tween = get_node(tween_path)


func _move_with_attack(
	move_impulse: Vector2, 
	move_duration: float, 
	move_delay: float = 0.0
):
	
	tween.interpolate_method(
		entity, 'do_movement', 
		Vector2.ZERO, move_impulse, move_duration, 
		Tween.TRANS_EXPO, Tween.EASE_OUT, 
		move_delay
	)
	entity.LOG.info("move {} -> {}, over {}s", 
		[
			entity.global_position, 
			entity.global_position + move_impulse, 
			move_duration
		]
	)
	if (not tween.is_active()):
		tween.start()
