extends Area2D
class_name AttackBox
"""
A type of area that describes the range and reach of an attack. 
This stores internally all Hitbox clients that it encounters and
forces them to process a hit when invoked
"""

"""
Type of damage this applies to the target.
"""
export(C.DamageType) var damage_type = C.DamageType.BLUNT
"""
Amount of raw damage dealt by attack
"""
export(float) var damage_amount = 0
"""
Attack vertical reach limit, regardless of attackbox size
Limited by attackbox actually overlapping hitbox
"""
export(float) var radius = 50.77
"""
Amount of diplacement to apply to target velocity 
during this hit. 
The direction is based on facing of attacker, not attacked
"""
export(Vector2) var target_move = Vector2.ZERO

var known_hitboxes = []
onready var shape: CollisionPolygon2D = get_child(0)


func _ready():
	#connect the hitbox registering signals
	connect("area_entered", self, "_on_area_entered")
	connect("area_exited", self, "_on_area_exited")


"""
Called externally during attack animations,
process hit on all hitboxes not currently disabled
"""
func process_attack() -> void:
	for node in known_hitboxes:
		var hitbox := node as Hitbox
		if (not hitbox.shape.disabled
			and _entity_in_radius(hitbox.owner)):
			hitbox.process_hit(self)


func _on_area_entered(area: Area2D) -> void:
	if (_is_valid_hitbox(area)):
		known_hitboxes.append(area)


func _on_area_exited(area: Area2D) -> void:
	var area_idx: int = known_hitboxes.find(area)
	if (area_idx >= 0):
		known_hitboxes.remove(area_idx)
	
	
func _is_valid_hitbox(area: Area2D) -> bool:
	return (
		is_instance_valid(area) 
		and area is Hitbox
		and area.owner != owner
	)
	
	
func _entity_in_radius(hitbox_owner: Node2D) -> bool:
	var attacker_position = owner.global_position
	var receiver_position = hitbox_owner.global_position
	Debug.add_global_draw({
		'type': 'line',
		'from': attacker_position,
		'to': receiver_position
	})
	var distance = abs(attacker_position.y - receiver_position.y)
	print("%s distance to %s: %s" % [attacker_position, receiver_position, distance] )
	var does_hit = distance <= radius
	return does_hit
	
	
func _to_string():
	return "AB[%s:%s]" % [owner.name, name]
