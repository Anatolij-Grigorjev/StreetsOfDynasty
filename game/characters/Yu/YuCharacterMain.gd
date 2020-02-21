extends CharacterTemplate
"""
Character behavior and nodes specific to Yu
"""


onready var anim: AnimationPlayer = $Body/YuCharacterRig/AnimationPlayer
onready var LOG: Logger = $Logger
onready var current_state_lbl: Label = $CurrentState


func _on_hitbox_hit(hitbox: Hitbox, attackbox: AttackBox):
	._on_hitbox_hit(hitbox, attackbox)
	LOG.info("{} got hit by {}!", [hitbox, attackbox])
	
	
func _on_FSM_state_changed(old_state: String, new_state: String):
	current_state_lbl.text = new_state
	
	
