extends Area2D
class_name Hitbox
"""
A type of area that describes where character can get hit on their body.
Defines which hit animation gets played during the hit
The expected client entity of this is a CharacterTemplate
"""
signal hitbox_hit(hit_connect)

onready var shape: CollisionPolygon2D = get_child(0)


func _ready():
	if (collision_mask):
		Debug.log_info("%s can make catch signals on mask %s", [self, collision_mask])
		connect("area_entered", self, "_on_area_entered")


func process_hit(attack) -> void:
	var attack_damage = rand_range(0.75, 1.25) * attack.damage_amount
	var hit_connect := HitConnect.new(self, attack, attack_damage)
	
	emit_signal("hitbox_hit", hit_connect)
		
		
func _to_string():
	return "HB[%s:%s]" % [owner.name, name]
