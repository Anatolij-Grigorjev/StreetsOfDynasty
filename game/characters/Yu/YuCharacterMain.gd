extends CharacterTemplate
"""
Character behavior and nodes specific to Yu
"""

onready var anim: AnimationPlayer = $Body/YuCharacterRig/AnimationPlayer
onready var LOG: Logger = $Logger


func _ready():
	connect("stability_reduced", fsm, "_on_character_reduce_stability")
	connect("damage_received", fsm, "_on_character_damage_received")
	connect("got_hit", fsm, "_on_character_got_hit")
	connect("hit_displaced", fsm, "_on_character_hit_displaced")
	connect("got_caught", fsm, "_on_character_got_caught")
	connect("caught_character", fsm, "_on_character_caught_character")
	

func _on_hitbox_hit(hit_connect: HitConnect):
	._on_hitbox_hit(hit_connect)
	LOG.info("Connected hit: {}!", [hit_connect])
		
		
func _to_string() -> String:
	return name
