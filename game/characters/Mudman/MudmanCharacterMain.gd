extends CharacterTemplate
"""
Main behavior script for Mudman
"""
var DamageLabel = preload("res://characters/DamageLabel.tscn")


onready var rig: Node2D = $Body/MudmanCharacterRig
onready var hit_effects: AttackTypeHitEffects = $Body/MudmanCharacterRig/AttackTypeHitEffects
onready var anim: AnimationPlayer = $Body/MudmanCharacterRig/AnimationPlayer
onready var current_state_lbl: Label = $CurrentState
onready var current_position_lbl: Label = $CurrentPosition
onready var healthbar = $Body/MudmanCharacterRig/HealthBar


func _process(delta):
	current_position_lbl.text = "%3.3f;%3.3f" % [global_position.x, global_position.y]


func _on_FSM_state_changed(old_state: String, new_state: String):
	current_state_lbl.text = new_state
	
func _on_hitbox_hit(hitbox: Hitbox, attackbox: AttackBox):
	._on_hitbox_hit(hitbox, attackbox)
	hit_effects.do_hit_effects(hitbox, attackbox)
	
	
	var multiplier = rand_range(0.75, 1.25)
	var damage = attackbox.damage_amount * multiplier
	
	var bar = healthbar.get_node("Bar")
	bar.value -= damage
	if (bar.value <= 0.0):
		bar.value = 100
	var label = DamageLabel.instance()
	label.position = rig.position
	label.movement *= rand_range(0.75, 1.75)
	label.global_position += Utils.rand_point(25, 25)
	add_child(label)
	label.set_damage(damage)
