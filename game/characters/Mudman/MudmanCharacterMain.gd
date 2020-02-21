extends CharacterTemplate
"""
Main behavior script for Mudman
"""

onready var anim: AnimationPlayer = $Body/MudmanCharacterRig/AnimationPlayer
onready var current_state_lbl: Label = $CurrentState


func _on_FSM_state_changed(old_state: String, new_state: String):
	current_state_lbl.text = new_state
