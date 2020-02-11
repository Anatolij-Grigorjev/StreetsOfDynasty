extends KinematicBody2D
class_name CharacterTemplate


export(Vector2) var move_speed: Vector2 = Vector2(4 * 64, 2 * 64)
var velocity = Vector2()


onready var anim: AnimationPlayer = $Body/CharacterRig/AnimationPlayer
onready var fsm: StateMachine = $FSM
onready var hitboxes: AreaGroup = $Body/HitboxGroup

var is_hurting = false

func _ready() -> void:
	for hitbox in hitboxes.get_children():
		hitbox.connect("hitbox_hit", self, "_on_hitbox_hit")
	
	
func _process(delta: float) -> void:
	pass
	
	
func _on_hitbox_hit(hitbox: Hitbox, attackbox: AttackBox):
	is_hurting = true
	#TODO: instance correct damage spark
	match(attackbox.damage_type):
		AttackBox.DamageType.BLUNT:
			pass
		AttackBox.DamageType.BLEEDING:
			pass
		_:
			print("Unknown damage type %s" % attackbox.damage_type)
			breakpoint
	pass
