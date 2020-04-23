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
onready var healthbar = $Body/MudmanCharacterRig/HealthBar


func _ready():
	connect("damage_received", healthbar, "_on_character_damage_received")
	healthbar.set_total(total_health)
	

func _process(delta):
	current_position_lbl.text = "%3.3f;%3.3f" % [global_position.x, global_position.y]


func _on_FSM_state_changed(old_state: String, new_state: String):
	current_state_lbl.text = new_state
	
func _on_hitbox_hit(hit_connect: HitConnect):
	._on_hitbox_hit(hit_connect)
	hit_effects.invoke_hit_effects(hit_connect)
	
	
	
func _do_die():
	var corpse = Corpse.instance()
	
	var corpses = Utils.get_node_by_tag("corpses")
	corpses.add_child(corpse)
	
	corpse.global_position = global_position
	corpse.get_node("AnimationPlayer").play("dead")
	
	queue_free()
	
