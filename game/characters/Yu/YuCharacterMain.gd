extends CharacterTemplate
"""
Character behavior and nodes specific to Yu
"""

onready var anim: AnimationPlayer = $Body/YuCharacterRig/AnimationPlayer
onready var LOG: Logger = $Logger


func _ready():
	fsm.connect("next_attack_input_changed", self, "_on_FSM_next_attack_input_changed")
	

func _on_hitbox_hit(hit_connect: HitConnect):
	._on_hitbox_hit(hit_connect)
	LOG.info("Connected hit: {}!", [hit_connect])
	
	
func _on_FSM_state_changed(old_state: String, new_state: String):
	pass
		
		
func _to_string() -> String:
	return name
