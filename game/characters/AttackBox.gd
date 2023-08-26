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
How much does this attack disrupt target stability
"""
export(float) var disruption = 15.7
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

onready var recent_attacks: RecentItemsDictionary = $RecentItemsDictionary
#first child is timed dict, so shape is second
onready var shape: CollisionShape2D = get_child(1)

#reference to potential character owner of this attackbox
#populated by AreaGroup if this node is part of an areagroup
var entity: Node2D


func _ready():
	recent_attacks.items_ttl_seconds = calc_attack_recovery()
	#connect the hitbox registering signals
	connect("area_entered", self, "_on_area_entered")
	connect("area_exited", self, "_on_area_exited")
	

func calc_attack_recovery() -> float:
	if not entity:
		return attack_recovery
	
	return attack_recovery / entity.anim.playback_speed


"""
Called externally during attack animations,
process hit on all hitboxes not currently disabled
"""
func process_attack() -> void:
	for node in known_hitboxes:
		var hitbox := node as Hitbox
		if (_hitbox_can_be_hit(hitbox)):
			hitbox.process_hit(self)
			_record_hitbox_recovery(hitbox)
			
			

func _record_hitbox_recovery(hitbox: Hitbox):
	recent_attacks.add_item(Utils.get_areagroup_area_owner(hitbox))
	

func _on_area_entered(area: Area2D) -> void:
	if (_is_valid_hitbox(area)):
		known_hitboxes.append(area)


func _on_area_exited(area: Area2D) -> void:
	var area_idx: int = known_hitboxes.find(area)
	if (area_idx >= 0):
		known_hitboxes.remove(area_idx)
	
	
func _is_valid_hitbox(area: Area2D) -> bool:
	var this_owner = Utils.get_areagroup_area_owner(self)
	var area_owner = Utils.get_areagroup_area_owner(area)
	return (
		is_instance_valid(area) 
		and area is Hitbox
		and area_owner != this_owner
	)
	
	
func _entity_in_radius(hitbox_owner: Node2D) -> bool:
	var this_owner = Utils.get_areagroup_area_owner(self)
	var attacker_position = this_owner.global_position
	var receiver_position = hitbox_owner.global_position
	Debug.add_global_draw({
		'type': Debug.DRAW_TYPE_LINE,
		'from': attacker_position,
		'to': receiver_position,
		'color': Color.red
	})
	
	return Utils.positions_in_z_range(
		attacker_position, 
		receiver_position, 
		radius
	)
	
	
func _hitbox_can_be_hit(hitbox: Hitbox) -> bool:
	var hitbox_owner = Utils.get_areagroup_area_owner(hitbox)
	return (
		#hitbox is enabled
		not hitbox.shape.disabled
		#attack is within range
		and _entity_in_radius(hitbox_owner)
		#enemy not currently invincible
		and not hitbox_owner.invincibility
		#attack didnt already hit recently
		and not recent_attacks.has_item(hitbox_owner)
	)
	
	
func _to_string():
	return "AB[%s:%s]" % [Utils.get_areagroup_area_owner(self), name]
