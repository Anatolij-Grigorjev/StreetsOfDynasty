extends KinematicBody2D
class_name CharacterTemplate
"""
Base class for game characters. 
Supports having hitboxes and attackboxes, receiving messages about
damage (foreign attackbox contact on own hitbox), sets move speed
"""
var Spark = preload("res://characters/spritefx/Spark.tscn")
var BluntHit = preload("res://characters/blunt_hit1.wav")

var damage_type_sounds: Dictionary = {
	AttackBox.DamageType.BLUNT: BluntHit,
	AttackBox.DamageType.BLEEDING: BluntHit
}

export(Vector2) var move_speed: Vector2 = Vector2(4 * 64, 2 * 64)
var velocity = Vector2()
var facing: int = 1


onready var fsm: StateMachine = $FSM
onready var hitboxes: AreaGroup = $Body/HitboxGroup
onready var attackboxes: AreaGroup = $Body/AttackboxGroup
onready var sound_player: AudioStreamPlayer2D = $CharacterFX


var is_hurting = false


func _ready() -> void:
	fsm.connect("state_changed", self, "_on_FSM_state_changed")
	for hitbox in hitboxes.get_children():
		var typed_hitbox: Hitbox = hitbox as Hitbox
		if (is_instance_valid(typed_hitbox)):
			typed_hitbox.connect("hitbox_hit", self, "_on_hitbox_hit")
	
	
func _process(delta: float) -> void:
	pass
	

func do_movement_collide(velocity: Vector2):
	move_and_collide(velocity)
	

"""
1-arg movement method for use in action tweens. 
This makes sure action tweens move character via velocity
and dont ignore kinematic collisions
"""
func do_movement_slide(velocity: Vector2):
	move_and_slide(velocity, Vector2.UP)
	
	
func _on_hitbox_hit(hitbox: Hitbox, attackbox: AttackBox):
	#character level indicator if a hurt-state is happening
	#gets reset when a state with a child HurtStateAspect exits
	is_hurting = true
	var spark_instance: Node2D = _build_random_spark(hitbox)
	var damage_type = randi() % AttackBox.DamageType.size() #attackbox.damage_type
	match(damage_type):
		AttackBox.DamageType.BLUNT:
			spark_instance.get_node("AnimationPlayer").play("blunt")
			pass
		AttackBox.DamageType.BLEEDING:
			spark_instance.get_node("AnimationPlayer").play("bleeding")
			pass
		_:
			print("Unknown damage type %s" % attackbox.damage_type)
			breakpoint
	if (not sound_player.playing):
		sound_player.stream = damage_type_sounds[damage_type]
		sound_player.play()
	if (attackbox.target_move != Vector2.ZERO):
		print("target_move: %s, attacker facing: %s, target facing: %s" % [attackbox.target_move, attackbox.owner.facing, facing])
		var displacement = attackbox.target_move
		fsm.hurt_move = displacement
	

func _build_random_spark(hitbox: Hitbox) -> Node2D:
	var hitbox_center_position = hitbox.shape.global_position
	var spark = Spark.instance()
	var position = Utils.rand_point(10, 5) + hitbox_center_position
	var rotation = randf() * 360
	add_child(spark)
	spark.global_position = position
	spark.global_rotation_degrees = rotation
	
	return spark
	
	
func _on_FSM_state_changed(old_state: String, new_state: String):
	pass
