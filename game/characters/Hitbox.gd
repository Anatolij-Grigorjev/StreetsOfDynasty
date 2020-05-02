extends Area2D
class_name Hitbox
"""
A type of area that describes where character can get hit on their body.
Defines which hit animation gets played during the hit
The expected client entity of this is a CharacterTemplate
"""
signal hitbox_hit(hit_connect)
signal hitbox_catch(enemy_hitbox)

export(float) var attack_recovery: float = 0.5
export(String) var hit_anim: String = "hit"
onready var shape: CollisionPolygon2D = get_child(0)

var recent_attacks: Dictionary = {}

func _ready():
	if (collision_mask):
		Debug.LOG.info("%s can make catch signals on mask %s", [self, collision_mask])
		connect("area_entered", self, "_on_area_entered")


func _process(delta):
	var recovered_attacks = []
	for attackbox in recent_attacks:
		recent_attacks[attackbox] -= delta
		if (recent_attacks[attackbox] <= 0.0):
			recovered_attacks.append(attackbox)

	for attackbox in recovered_attacks:
		Debug.LOG.info("%s Receovered from %s", [self, attackbox])
		recent_attacks.erase(attackbox)


func process_hit(attack) -> void:
	if (not recent_attacks.has(attack)):
		Debug.LOG.info("%s recover from %s in %s seconds...", [self, attack, attack_recovery])
		recent_attacks[attack] = attack_recovery
		var attack_damage = rand_range(0.75, 1.25) * attack.damage_amount
		var hit_connect := HitConnect.new(self, attack, attack_damage)
		
		emit_signal("hitbox_hit", hit_connect)
		
		
func _to_string():
	return "HB[%s:%s]" % [owner.name, name]
	
	
func _on_area_entered(area: Area2D):
	if (area.owner != owner and 
	not area.owner.invincibility):
		emit_signal("hitbox_catch", area)
