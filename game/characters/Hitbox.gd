extends Area2D
class_name Hitbox
"""
A type of area that describes where character can get hit on their body.
Defines which hit animation gets played during the hit
The expected client entity of this is a CharacterTemplate
"""
signal hitbox_hit(hitbox, attackbox)


export(String) var hit_anim: String = "hit"


func process_hit(attack) -> void:
	emit_signal("hitbox_hit", self, attack)