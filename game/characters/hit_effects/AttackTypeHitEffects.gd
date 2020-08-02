extends Node2D
class_name AttackTypeHitEffects
"""
This controller uses its HitEffect children to determine what 
effect to play for a suffered hit on its parent entity
"""
export(Dictionary) var damage_type_effect_idx_map = {
	C.DamageType.BLUNT: 0,
	C.DamageType.BLEEDING: 1
}

onready var entity = owner
var attack_type_hit_effects: Array = []
var default_hit_effects: Array = []



func _ready():
	for child in get_children():
		if (child as HitEffects):
			attack_type_hit_effects.append(child)
		if (child is HitEffectTemplate):
			default_hit_effects.append(child)
	
	
func invoke_hit_effects(hit_connect: HitConnect, invoke_named: Array = []):
	var effect_idx = damage_type_effect_idx_map[hit_connect.attack_damage_type]
	var typed_hit_effect = attack_type_hit_effects[effect_idx] as HitEffects
	if (typed_hit_effect):
		typed_hit_effect.invoke_hit_fx(hit_connect, invoke_named)
	else:
		Debug.log_warn("No hit effects found for idx {} in effects array {}", [effect_idx, attack_type_hit_effects])
		breakpoint
	for default_effect in default_hit_effects:
		default_effect.invoke_hit_fx(hit_connect)
