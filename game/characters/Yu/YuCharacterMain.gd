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
	connect("got_caught", fsm, "_on_character_got_caught")
	connect("landed_hit", self, "_on_landed_hit")
	

func _on_hitbox_hit(hit_connect: HitConnect):
	._on_hitbox_hit(hit_connect)
	LOG.info("Connected hit: {}!", [hit_connect])
	

func _process(delta):
	if (Debug.get_debug1_pressed()):
		emit_signal("got_hit", HitConnect.new(
			$Body/YuCharacterRig/HitboxGroup/Idle,
			$Body/YuCharacterRig/AttackboxGroup/AttackA1,
			rand_range(7.0, 14.0)
		))
		
		
func _to_string() -> String:
	return name
		
		
func _on_landed_hit(hit_connect: HitConnect):
	$Body/YuCharacterRig/AttackTypeHitEffects.invoke_hit_effects(hit_connect)
	
