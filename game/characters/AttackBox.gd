extends Area2D
class_name AttackBox
"""
A type of area that describes the range and reach of an attack. 
This stores internally all Hitbox clients that it encounters and
forces them to process a hit when invoked
"""
export(NodePath) var entity_path: NodePath = NodePath("..")
onready var entity: CharacterTemplate = get_node(entity_path)


var known_hitboxes = []


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
	known_hitboxes.remove(area_idx)
	
	
func _is_valid_hitbox(area: Area2D) -> bool:
	return (
		is_instance_valid(area) 
		and area is Hitbox
	)
