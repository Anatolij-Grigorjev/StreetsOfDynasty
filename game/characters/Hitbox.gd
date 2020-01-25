extends Area2D
class_name Hitbox
"""
A type of area that describes where character can get hit on their body.
Defines which hit animation gets played during the hit
The expected client entity of this is a CharacterTemplate
"""
export(NodePath) var entity_path: NodePath = NodePath("..")
export(String) var hit_anim: String = "hit"

onready var entity: CharacterTemplate = get_node(entity_path)



func process_hit() -> void:
	print(entity.name + "." + name + ":" + " got hit")