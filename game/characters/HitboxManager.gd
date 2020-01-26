extends Node2D
class_name HitboxManager
"""
Utility to switch between active hitboxes, invoked by animator
and send signal about a hit hitbox to parents
"""
signal hitbox_hit(hitbox, attackbox)

export(NodePath) var entity_path := NodePath("..")
export(String) var active_hitbox := ""


onready var all_hitboxes := {}
onready var entity := get_node(entity_path)


func _ready() -> void:
	for node in get_children():
		if (node is Hitbox):
			var hitbox := node as Hitbox
			all_hitboxes[hitbox.name] = hitbox
	

"""
Called by animator, switch to a specific named hitbox
and disable all others
"""
func switch_to_hitbox(hitbox_name: String) -> void:
	_disable_all_hitboxes()
	_enable_hitbox(hitbox_name)


"""
resolve intersection of THIS hitbox with THIS attackbox
if the attack is valid (in range, etc), emit hte signal
"""
func resolve_attack_hitbox(attack_node, hitbox: Hitbox) -> void:
	var attack := attack_node as AttackBox
	#TODO: does the attackbox land the hit?
	emit_signal("hitbox_hit", hitbox, attack)


func _disable_all_hitboxes() -> void:
	for hitbox_name in all_hitboxes:
		(all_hitboxes[hitbox_name] as Hitbox).shape.disabled = true
		
		
func _enable_hitbox(hitbox_name: String) -> void:
	if (all_hitboxes.has(hitbox_name)):
		(all_hitboxes[hitbox_name] as Hitbox).shape.disabled = false