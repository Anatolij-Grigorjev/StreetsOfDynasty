extends HitEffectTemplate
class_name AttackerImpactHitEffect
"""
A kind of hit effect that sells hit impact by freezing attacker
 animation for a short duration
"""

"""
The slow factor applied to regular attacker animation speed
"""
export(float) var anim_slow_factor: float = 0.1
"""
Amount of time attacker animation will stay slow
"""
export(float) var anim_slow_duration: float = 0.1


onready var timer: Timer = $Timer

var prev_attacker_anim_speed: float = 1.0
var attacker: CharacterTemplate


func _ready():
	timer.one_shot = true
	timer.wait_time = anim_slow_duration
	timer.connect("timeout", self, "_on_anim_slowdown_timeout")
	
	

func invoke_hit_fx(hit_connect: HitConnect):
	attacker = hit_connect.attacker
	prev_attacker_anim_speed = attacker.anim.playback_speed
	attacker.anim.playback_speed = anim_slow_factor
	timer.start()
	
	
func _on_anim_slowdown_timeout():
	attacker.anim.playback_speed = prev_attacker_anim_speed
	prev_attacker_anim_speed = 1.0
	attacker = null
