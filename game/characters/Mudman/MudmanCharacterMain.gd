extends CharacterTemplate
"""
Main behavior script for Mudman
"""
var Corpse = preload("res://characters/Mudman/MudmanCharacterRig.tscn")


onready var rig: Node2D = $Body/MudmanCharacterRig
onready var hit_effects: AttackTypeHitEffects = $Body/MudmanCharacterRig/AttackTypeHitEffects
onready var anim: AnimationPlayer = $Body/MudmanCharacterRig/AnimationPlayer
onready var current_state_lbl: Label = $CurrentState
onready var current_position_lbl: Label = $CurrentPosition
onready var current_stability_lbl: Label = $CurrentStability
onready var healthbar = $Body/MudmanCharacterRig/HealthbarHolder/HealthBar


func _ready():
	connect("damage_received", healthbar, "_on_character_damage_received")
	healthbar.set_total(total_health)
	
	connect("damage_received", fsm, "_on_character_damage_received")
	

func _process(delta):
	current_position_lbl.text = "%3.3f;%3.3f" % [global_position.x, global_position.y]
	current_stability_lbl.text = "ST: %d" % stability


func _on_FSM_state_changed(old_state: String, new_state: String):
	current_state_lbl.text = new_state
	
	
func _on_hitbox_hit(hit_connect: HitConnect):
	._on_hitbox_hit(hit_connect)
	hit_effects.invoke_hit_effects(hit_connect)
	
	
func _set_caught(got_caught: bool):
	._set_caught(got_caught)
	fsm.set_post_caught_state("Falling")


func _to_string():
	return "[%s]" % name


func _on_HitEffect_color_flash_hit_received(color: Color, duration: float):
	var sprite_node = rig.get_node("Sprite")
	sprite_node.use_parent_material = false
	sprite_node.material.set_shader_param("modulate", Color.black)
	yield(get_tree().create_timer(duration), "timeout")
	sprite_node.use_parent_material = true
