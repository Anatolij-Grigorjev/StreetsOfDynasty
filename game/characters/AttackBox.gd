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
"""
How long cooldown between hitting same hitbox with this same attackbox
"""
export(float) var attack_recovery: float = 0.5

var known_hitboxes = []
onready var shape: CollisionPolygon2D = get_child(0)


var recent_attacks: Dictionary = {}


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
		if (
			#hitbox is enabled
			not hitbox.shape.disabled
			#attack is within range
			and _entity_in_radius(hitbox.owner)
			#enemy not currently invincible
			and not hitbox.owner.invincibility
			#attack didnt already hit recently
			and not recent_attacks.has(hitbox)
		):
			hitbox.process_hit(self)
			_record_hitbox_recovery(hitbox)
			
			

func _record_hitbox_recovery(hitbox: Hitbox):
	recent_attacks[hitbox] = attack_recovery


func _process(delta: float):
	_process_hitbox_recovery(delta)
	

"""
Recover attack cooldowns for hitboxes
"""
func _process_hitbox_recovery(delta: float):
	var recovered_hitboxes = []
	for hitbox in recent_attacks:
		recent_attacks[hitbox] -= delta
		if (recent_attacks[hitbox] <= 0.0):
			recovered_hitboxes.append(hitbox)
	for hitbox in recovered_hitboxes:
		Debug.LOG.info("%s can hit %s", [self, hitbox])
		recent_attacks.erase(hitbox)
	


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
		'type': Debug.DRAW_TYPE_LINE,
		'from': attacker_position,
		'to': receiver_position,
		'color': Color.red
	})
	var distance = abs(attacker_position.y - receiver_position.y)
	print("%s distance to %s: %s" % [attacker_position, receiver_position, distance] )
	var does_hit = distance <= radius
	return does_hit
	
	
func _to_string():
	return "AB[%s:%s]" % [owner.name, name]
