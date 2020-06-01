extends CharacterTemplate
"""
Main behavior script for Mudman
"""
var idle_stability_recovery_per_sec: float = 5
var hurt_stability_recovery_per_sec: float = 20

onready var rig: Node2D = $Body/MudmanCharacterRig
onready var anim: AnimationPlayer = $Body/MudmanCharacterRig/AnimationPlayer


func _ready():
	
	var healthbar = $Body/MudmanCharacterRig/HealthbarHolder/HealthBar
	connect("damage_received", healthbar, "_on_character_damage_received")
	healthbar.set_total(total_health)
	
	fsm.connect("state_changed", $InvincibilityBlinker, "_on_CharacterTemplate_state_changed")
	
	connect("stability_reduced", fsm, "_on_character_reduce_stability")
	connect("damage_received", fsm, "_on_character_damage_received")
	connect("got_hit", fsm, "_on_character_got_hit")
	connect("hit_displaced", fsm, "_on_character_hit_displaced")
	connect("got_caught", fsm, "_on_character_got_caught")
	connect("got_released", fsm, "_on_character_got_released")
	
	
	var hit_effects: AttackTypeHitEffects = $Body/MudmanCharacterRig/AttackTypeHitEffects
	for hitbox in hitboxes.get_children():
		if (hitbox as Hitbox):
			hitbox.connect("hitbox_hit", hit_effects, "invoke_hit_effects")
	

func _get_stability_recovery_per_sec() -> float:
	if (stability > 50):
		return idle_stability_recovery_per_sec
	elif (stability > 0):
		return hurt_stability_recovery_per_sec
	else:
		return total_stability


func _on_FSM_state_changed(old_state: String, new_state: String):
	pass


func _to_string():
	return name


func _on_HitEffect_flash_hit_received(color: Color, duration: float):
	var sprite_node = rig.get_node("Sprite")
	sprite_node.use_parent_material = false
	sprite_node.material.set_shader_param("modulate", color)
	yield(get_tree().create_timer(duration), "timeout")
	sprite_node.use_parent_material = true
