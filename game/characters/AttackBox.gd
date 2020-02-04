extends Area2D
class_name AttackBox
"""
A type of area that describes the range and reach of an attack. 
This stores internally all Hitbox clients that it encounters and
forces them to process a hit when invoked
"""

var known_hitboxes = []


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
		if (not hitbox.shape.disabled):
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
