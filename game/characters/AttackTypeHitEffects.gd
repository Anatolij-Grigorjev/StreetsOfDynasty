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
		if (child as HitEffect):
			hit_effects.append(child)
	
	
func do_hit_effects(hit_hitbox: Hitbox, attack_attackbox: AttackBox):
	var effect_idx = damage_type_effect_idx_map[attack_attackbox.damage_type]
	var hit_effect = hit_effects[effect_idx] as HitEffect
	if (hit_effect):
		hit_effect.invoke_hit_fx(hit_hitbox, attack_attackbox)
	else:
		print("No hit effect found for idx %s in effects array %s" % [effect_idx, hit_effects])
		breakpoint
