extends CharacterTemplate
"""
Main behavior script for Mudman
"""
var DamageLabel = preload("res://characters/DamageLabel.tscn")


onready var rig: Node2D = $Body/MudmanCharacterRig
onready var anim: AnimationPlayer = $Body/MudmanCharacterRig/AnimationPlayer
onready var current_state_lbl: Label = $CurrentState
onready var healthbar = $Body/MudmanCharacterRig/HealthBar



func _on_FSM_state_changed(old_state: String, new_state: String):
	current_state_lbl.text = new_state
	
func _on_hitbox_hit(hitbox: Hitbox, attackbox: AttackBox):
	._on_hitbox_hit(hitbox, attackbox)
	var damage = rand_range(3.5, 7.5)
	
	var bar = healthbar.get_node("Bar")
	bar.value -= damage
	if (bar.value <= 0.0):
		healthbar.hide()
	var label = DamageLabel.instance()
	label.position = rig.position
	label.global_position += Vector2.ONE * rand_range(-25, 25)
	add_child(label)
	label.set_damage(damage)
