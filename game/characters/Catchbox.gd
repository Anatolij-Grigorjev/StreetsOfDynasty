extends Area2D
class_name Catchbox
"""
A type of area that allows 'catching' other characters by the hitbox
When a hitbox passes this collision mask and is within radius,
the catchbox sends a catching signal about the caught hitbox
"""
signal caught(enemy_hitbox)

export(float) var catch_radius: float = 35.77

# reference to owner entity of this catchbox. populated by
# owning catchbox area group, if this node is part of a group
var entity: Node2D


func _ready():
	Debug.log_info("%s can make catch signals on mask %s", [self, collision_mask])
	connect("area_entered", self, "_on_area_entered")
	

func _to_string() -> String:
	return "CB[%s:%s]" % [entity, name]
	
	
func _on_area_entered(area: Area2D):
	if (not visible): 
		return
	var enemy_hitbox_owner = Utils.get_areagroup_area_owner(area)
	var this_hitbox_owner = entity
	if (enemy_hitbox_owner != this_hitbox_owner and 
	not enemy_hitbox_owner.invincibility):
		var target_pos = enemy_hitbox_owner.global_position
		var pos = this_hitbox_owner.global_position
		if (abs(target_pos.y - pos.y) <= catch_radius):
			emit_signal("caught", area)
		else:
			Debug.add_global_draw({
				'type': Debug.DRAW_TYPE_LINE,
				'from': target_pos,
				'to': pos,
				'color': Color.blue,
				'duration': 0.5
			})
