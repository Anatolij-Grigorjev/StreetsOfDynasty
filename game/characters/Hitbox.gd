extends Area2D
class_name Hitbox
"""
A type of area that describes where character can get hit on their body.
Defines which hit animation gets played during the hit
The expected client entity of this is a CharacterTemplate
"""
signal hitbox_hit(hit_connect)
signal hitbox_catch(enemy_hitbox)

export(float) var catch_radius: float = 35.77

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
	
	
func _on_area_entered(area: Area2D):
	var enemy_hitbox_owner = Utils.get_areagroup_area_owner(area)
	var this_hitbox_owner = Utils.get_areagroup_area_owner(self)
	if (enemy_hitbox_owner != this_hitbox_owner and 
	not enemy_hitbox_owner.invincibility):
		var target_pos = enemy_hitbox_owner.global_position
		var pos = this_hitbox_owner.global_position
		if (abs(target_pos.y - pos.y) <= catch_radius):
			emit_signal("hitbox_catch", area)
		else:
			Debug.add_global_draw({
				'type': Debug.DRAW_TYPE_LINE,
				'from': target_pos,
				'to': pos,
				'color': Color.blue,
				'duration': 0.5
			})
