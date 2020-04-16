extends Area2D
class_name Hitbox
"""
A type of area that describes where character can get hit on their body.
Defines which hit animation gets played during the hit
The expected client entity of this is a CharacterTemplate
"""
signal hitbox_hit(hit_connect)

export(float) var attack_recovery: float = 0.5
export(String) var hit_anim: String = "hit"
onready var shape: CollisionPolygon2D = get_child(0)

var recent_attacks: Dictionary = {}


func _process(delta):
	var recovered_attacks = []
	for attackbox in recent_attacks:
		recent_attacks[attackbox] -= delta
		if (recent_attacks[attackbox] <= 0.0):
			recovered_attacks.append(attackbox)

	for attackbox in recovered_attacks:
		recent_attacks.erase(attackbox)


func process_hit(attack) -> void:
	if (not recent_attacks.has(attack)):
		recent_attacks[attack] = attack_recovery
		var hit_connect := HitConnect.new(self, attack)
		
		emit_signal("hitbox_hit", hit_connect)
		
		
func _to_string():
	return "HB[%s:%s]" % [owner.name, name]
