extends Node2D
class_name HitEffect
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


func invoke_hit_fx(hit_connect: HitConnect):
	#hit spark
	var spark = _build_random_spark()
	add_child(spark)
	spark.get_node("AnimationPlayer").play(spark_anim)
	
	#hit particles
	_add_particles(spark.position, hit_connect.attack_facing)
	
	#hit sound
	_play_hit_sound()
	
	#hit screenshake
	screen_shake.request_screen_shake()
	pass
	
	
func _build_random_spark() -> Node2D:
	
	var spark = Spark.instance()
	spark.global_position = Utils.rand_point(10, 5)
	spark.rotation = randf() * 360
	spark.scale = Vector2.ONE * rand_range(1.0, 2.0)
	
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
