extends CharacterTemplate
"""
Character behavior and nodes specific to Yu
"""


onready var anim: AnimationPlayer = $Body/YuCharacterRig/AnimationPlayer
onready var LOG: Logger = $Logger


func _on_hitbox_hit(hitbox: Hitbox, attackbox: AttackBox):
	._on_hitbox_hit(hitbox, attackbox)
	LOG.info("{} got hit by {}!", [hitbox, attackbox])
	
	
