extends Area2D
class_name Hitbox
"""
A type of area that describes where character can get hit on their body.
Defines which hit animation gets played during the hit
The expected client entity of this is a CharacterTemplate
"""
export(NodePath) var hitbox_manager_path: NodePath = NodePath("..")
export(String) var hit_anim: String = "hit"

onready var hitbox_manager = get_node(hitbox_manager_path)
onready var shape: CollisionShape2D = get_child(0)


func process_hit(attack) -> void:
	hitbox_manager.resolve_attack_hitbox(attack, self)