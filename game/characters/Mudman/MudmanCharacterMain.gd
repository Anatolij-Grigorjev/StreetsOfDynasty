extends CharacterTemplate
"""
Main behavior script for Mudman
"""
var idle_stability_recovery_per_sec: float = 5
var hurt_stability_recovery_per_sec: float = 20

onready var rig: Node2D = $Body/MudmanCharacterRig
onready var hit_effects: AttackTypeHitEffects = $Body/MudmanCharacterRig/AttackTypeHitEffects
onready var anim: AnimationPlayer = $Body/MudmanCharacterRig/AnimationPlayer
onready var current_state_lbl: Label = $CurrentState
onready var current_position_lbl: Label = $CurrentPosition
onready var current_stability_lbl: Label = $CurrentStability


func _ready():
	
	var healthbar = $Body/MudmanCharacterRig/HealthbarHolder/HealthBar
	connect("damage_received", healthbar, "_on_character_damage_received")
	healthbar.set_total(total_health)
	
	
	connect("damage_received", fsm, "_on_character_damage_received")
	
	fsm.connect("state_changed", $InvincibilityBlinker, "_on_CharacterTemplate_state_changed")
	
	for hitbox in hitboxes.get_children():
		var typed_hitbox: Hitbox = hitbox as Hitbox
		if (is_instance_valid(typed_hitbox)):
			typed_hitbox.connect("hitbox_hit", hit_effects, "invoke_hit_effects")
			
	

func _get_stability_recovery_per_sec() -> float:
	if (stability > 50):
		return idle_stability_recovery_per_sec
	elif (stability > 0):
		return hurt_stability_recovery_per_sec
	else:
		return total_stability



func _process(delta):
	current_position_lbl.text = "%3.3f;%3.3f" % [global_position.x, global_position.y]
	current_stability_lbl.text = "ST: %d" % stability


func _on_FSM_state_changed(old_state: String, new_state: String):
	current_state_lbl.text = new_state
	
	
func _set_caught(got_caught: bool):
	._set_caught(got_caught)
	fsm.set_post_caught_state("Falling")


func _to_string():
	return "[%s]" % name


func _on_HitEffect_flash_hit_received(color: Color, duration: float):
	var sprite_node = rig.get_node("Sprite")
	sprite_node.use_parent_material = false
	sprite_node.material.set_shader_param("modulate", color)
	yield(get_tree().create_timer(duration), "timeout")
	sprite_node.use_parent_material = true
