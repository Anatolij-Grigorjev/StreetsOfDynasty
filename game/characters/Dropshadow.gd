extends Node2D
"""
On-ground shadow that moves with character. 
Gets smaller during jumps
"""

"""
Amoutn of scale removed from shadow sprite per 100 pixels of lift
For example at 0.2 the shadow will turn invisible with 500 pixels lift
"""
const LIFTED_SIZE_REDUCTION = 0.2

onready var character = get_parent() as CharacterTemplate
onready var tween = $Tween
onready var shadow = $Sprite

var pre_reduce_scale: Vector2

func _ready():
	character.connect("rig_lift_started", self, "_character_rig_lift_started")



func _character_rig_lift_started(total_lift: float, lift_velocity: Vector2):
	pre_reduce_scale = shadow.scale
	var remaining_shadow_scale: float = max(0.0, abs(1.0 - (abs(total_lift) / 100.0 * LIFTED_SIZE_REDUCTION)))
	var target_scale = pre_reduce_scale * remaining_shadow_scale
	var duration: float = abs(total_lift / max(0.1, abs(lift_velocity.y)))
	var drop_duration = abs(total_lift / Utils.sqr(C.GRAVITY))
	
	Debug.log_debug("TWEENING scale: {} -> {} over {}s and dropping over {}s", [pre_reduce_scale, target_scale, duration, drop_duration])
	
	tween.interpolate_property(
		shadow, 'scale', 
		pre_reduce_scale, target_scale, 
		duration, Tween.TRANS_EXPO, Tween.EASE_OUT
	)
	tween.interpolate_property(
		shadow, 'scale',
		target_scale, pre_reduce_scale,
		drop_duration, Tween.TRANS_EXPO, Tween.EASE_IN, 
		duration
	)
	tween.start()
