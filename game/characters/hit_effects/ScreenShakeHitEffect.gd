extends HitEffectTemplate
"""
A knd of hit effect that signals for a screen shake via a 
ScreenShakeRequestor
"""

onready var client = $ScreenShakeRequestor


func invoke_hit_fx(hit_connect: HitConnect):
	
	#TODO: use hit props to customize screen shake
	
	client.build_screen_shake({
		'duration': 0.2, 
		'frequency': 15, 
		'amplitude': 10, 
		'priority': 1 
	})
