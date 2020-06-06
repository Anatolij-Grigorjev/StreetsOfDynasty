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
var hit_effects: Array = []



func _ready():
	for child in get_children():
		if (child as HitEffects):
			hit_effects.append(child)
	
	
func invoke_hit_effects(hit_connect: HitConnect, invoke_named: Array = []):
	var effect_idx = damage_type_effect_idx_map[hit_connect.attack_damage_type]
	var hit_effect = hit_effects[effect_idx] as HitEffects
	if (hit_effect):
		hit_effect.invoke_hit_fx(hit_connect, invoke_named)
	else:
		Debug.log_warn("No hit effects found for idx {} in effects array {}", [effect_idx, hit_effects])
		breakpoint
