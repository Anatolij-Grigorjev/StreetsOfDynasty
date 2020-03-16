extends CharacterTemplate
"""
Main behavior script for Mudman
"""

onready var anim: AnimationPlayer = $Body/MudmanCharacterRig/AnimationPlayer
onready var current_state_lbl: Label = $CurrentState
onready var healthbar = $Body/MudmanCharacterRig/HealthBar



func _on_FSM_state_changed(old_state: String, new_state: String):
	current_state_lbl.text = new_state
	
func _on_hitbox_hit(hitbox: Hitbox, attackbox: AttackBox):
	._on_hitbox_hit(hitbox, attackbox)
	var bar = healthbar.get_node("Bar")
	bar.value -= rand_range(3.5, 7.5)
	if (bar.value <= 0.0):
		healthbar.hide()

