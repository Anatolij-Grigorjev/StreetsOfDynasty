extends Node2D
class_name HitEffects
"""
Hit effects that has several effect children 
which all play to juice the hit
"""


var hit_effects: Array = []


func _ready():
	for child in get_children():
		var hit_effect: HitEffectTemplate = child as HitEffectTemplate
		if (hit_effect):
			hit_effects.append(hit_effect)
			
	Debug.log_info("{} registered {} hit effects!", [self.name, hit_effects.size()])


func invoke_hit_fx(hit_connect: HitConnect, invoke_named: Array = []):
	
	if (invoke_named.empty() or invoke_named.size() >= hit_effects.size()):
		#invoke all hit effects
		for node in hit_effects:
			var effect = node as HitEffectTemplate
			effect.invoke_hit_fx(hit_connect)
	else:
		#check effect before invoke
		var invoke_names_string: String = Utils.join_to_string(invoke_named)
		Debug.log_info("Invoking effects sequence: {}", [invoke_names_string])
		for node in hit_effects:
			var effect = node as HitEffectTemplate
			if (invoke_names_string.find(effect.shortname) >= 0):
				effect.invoke_hit_fx(hit_connect)
