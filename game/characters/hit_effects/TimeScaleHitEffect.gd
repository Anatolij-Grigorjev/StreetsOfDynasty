extends HitEffectTemplate
"""
A kind of hit effect that scales engine time during hit
"""
signal timescale_requested(scale, duration, priority)

export(float) var timescale_damage_threshold = 5
export(float) var timescale_duration = 0.15


func invoke_hit_fx(hit_connect: HitConnect):
	if (hit_connect.attack_damage <= timescale_damage_threshold):
		return
	var slow_down = 100.0/(100.0 + hit_connect.attack_damage)
	if (slow_down < 1.0):
		emit_signal("timescale_requested", slow_down, 0.15, 1)
