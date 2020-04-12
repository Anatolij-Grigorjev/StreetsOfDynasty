extends KinematicBody2D
class_name CharacterTemplate
"""
Base class for game characters. 
Supports having hitboxes and attackboxes, receiving messages about
damage (foreign attackbox contact on own hitbox), sets move speed
"""
var Spark = preload("res://characters/spritefx/Spark.tscn")
var BluntHit = preload("res://characters/blunt_hit1.wav")
var BluntHitHeavy = preload("res://characters/blunt_hit_heavy1.wav")

var damage_type_sounds: Dictionary = {
	AttackBox.DamageType.BLUNT: BluntHitHeavy,
	AttackBox.DamageType.BLEEDING: BluntHitHeavy
}

export(Vector2) var move_speed: Vector2 = Vector2(4 * 64, 2 * 64)
export(Vector2) var sprite_size: Vector2 = Vector2.ZERO
var velocity = Vector2()
var facing: int = 1


onready var fsm: StateMachine = $FSM
onready var body: Node2D = $Body
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
	_add_blood_splatter(spark_instance.position, attackbox.owner.facing)
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
	_handle_play_hit_sound(damage_type)
	_handle_hit_displacement(attackbox)
	

func _build_random_spark(hitbox: Hitbox) -> Node2D:
	var hitbox_center_position = hitbox.shape.global_position
	var spark = Spark.instance()
	var position = Utils.rand_point(10, 5) + hitbox_center_position
	var rotation = randf() * 360
	var scale = rand_range(1.0, 2.0)
	add_child(spark)
	spark.global_position = position
	spark.global_rotation_degrees = rotation
	spark.global_scale = Vector2(scale, scale)
	
	return spark
	

func _add_blood_splatter(local_position: Vector2, facing: int):
	var particles = get_node('BloodParticles') as Particles2D
	particles.position = local_position
	particles.process_material.direction.x *= facing
	particles.emitting = true
	
	
	
func _handle_play_hit_sound(damage_type: int): 
	if (sound_player.is_playing()):
		return
	var sound_file = damage_type_sounds[damage_type]
	if (not sound_file):
		print("No sound assigned for damage type ", damage_type)
		breakpoint
	var db_scale = 0.25
	var pitch_scale = 0.25
	sound_player.stream = sound_file
	sound_player.volume_db = rand_range(-db_scale, db_scale)
	sound_player.pitch_scale = rand_range(1 - pitch_scale, 1 + pitch_scale)
	sound_player.play()
	
	
func _handle_hit_displacement(attackbox: AttackBox):
	if (attackbox.target_move != Vector2.ZERO):
		print(
			"target_move: %s, attacker facing: %s, target facing: %s" % 
			[attackbox.target_move, attackbox.owner.facing, facing]
		)
		var displacement = attackbox.target_move * attackbox.owner.facing
		fsm.hurt_move = displacement
	
	
func _on_FSM_state_changed(old_state: String, new_state: String):
	pass
