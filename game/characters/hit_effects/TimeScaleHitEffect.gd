extends HitEffectTemplate
"""
A kind of hit effect that scales engine time during hit
"""
export(float) var timescale_damage_threshold = 5
export(float) var timescale_duration = 0.15


func invoke_hit_fx(hit_connect: HitConnect):
	if (hit_connect.attack_damage <= timescale_damage_threshold):
		return
	var slow_down = 100.0/(100.0 + hit_connect.attack_damage)
	if (slow_down < 1.0):
		Engine.time_scale *= slow_down
		#duration here is not scaled by slowdown
		#this way the impact is felt harder for bigger slowdown
		yield(get_tree().create_timer(timescale_duration), "timeout")
		Engine.time_scale = 1.0
