extends Node2D
class_name HitEffect
"""
Hit effects sprite that has several effect children 
which all play to juice the hit
"""

onready var screen_shake: ScreenShakeRequestor = $ScreenShakeRequestor


func invoke_hit_fx(hit_connect: HitConnect):
	
	#feel hit impact
	_time_hit_impact(hit_connect)
	
	#hit screenshake
	screen_shake.request_screen_shake()
	pass
	
	
func _time_hit_impact(hit_details: HitConnect):
	var slowing_damage = clamp(
		hit_details.attack_damage - C.LOW_IMPACT_ATTACK_DAMAGE, 
		0, hit_details.attack_damage
	)
	var slow_down = 100.0/(100.0 + slowing_damage)
	if (slow_down < 1.0):
		var prev_scale = Engine.time_scale
		Engine.time_scale *= slow_down
		yield(get_tree().create_timer(0.15), "timeout")
		Engine.time_scale = prev_scale

