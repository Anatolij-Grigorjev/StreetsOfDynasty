extends Node2D
"""
Hit effects sprite that has several effect children 
which all play to juice the hit
"""
var Spark = preload("res://characters/spritefx/Spark.tscn")

export(AudioStream) var HitSoundFx
export(String) var spark_anim


onready var sound_player: AudioStreamPlayer2D = $SoundFX
onready var hit_particles: Particles2D = $HitParticles
onready var screen_shake: ScreenShakeRequestor = $ScreenShakeRequestor


func _ready():
	sound_player.stream = HitSoundFx
	
	pass


func invoke_hit_fx(hit_hitbox: Hitbox, attack_attackbox: AttackBox):
	#hit spark
	var spark = _build_random_spark(hit_hitbox)
	add_child(spark)
	spark.get_node("AnimationPlayer").play("bleeding")
	
	#hit particles
	_add_particles(spark.local_position, attack_attackbox.owner.facing)
	
	#hit sound
	_play_hit_sound()
	
	#hit screenshake
	screen_shake.request_screen_shake()
	pass
	
	
func _build_random_spark(hitbox: Hitbox) -> Node2D:
	var hitbox_center_position = hitbox.shape.global_position
	
	var spark = Spark.instance()
	var position = Utils.rand_point(10, 5) + hitbox_center_position
	var rotation = randf() * 360
	var scale = rand_range(1.0, 2.0)
	spark.global_position = position
	spark.global_rotation_degrees = rotation
	spark.global_scale = Vector2(scale, scale)
	
	return spark
	
	
func _add_particles(local_position: Vector2, attack_facing: int):
	hit_particles.position = local_position
	hit_particles.process_material.direction.x *= attack_facing
	hit_particles.restart()
	hit_particles.emitting = true


func _play_hit_sound(): 
	if (sound_player.is_playing()):
		return
	var db_scale = 0.25
	var pitch_scale = 0.25
	sound_player.volume_db = rand_range(-db_scale, db_scale)
	sound_player.pitch_scale = rand_range(1 - pitch_scale, 1 + pitch_scale)
	
	sound_player.play()