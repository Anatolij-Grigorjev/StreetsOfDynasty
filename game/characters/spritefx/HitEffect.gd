extends Node2D
class_name HitEffect
"""
Hit effects sprite that has several effect children 
which all play to juice the hit
"""
var Spark = preload("res://characters/spritefx/Spark.tscn")
var DamageLabel = preload("res://characters/DamageLabel.tscn")

export(AudioStream) var HitSoundFx
export(String) var spark_anim: String
export(Color) var label_color: Color


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
	
	#hit damage label
	var label = _build_damage_label(hit_connect)
	label.global_position = (
		#at spark pos
		spark.global_position 
		#with some randomness
		+ owner.facing * Utils.rand_point(25.0, 25.0)
	)
	#set_damage requires label in tree
	_add_at_scene_root(label)
	
	label.set_damage(-hit_connect.attack_damage)
	
	#hit particles
	_add_particles(spark.position, hit_connect.attack_facing)
	
	#hit sound
	_play_hit_sound()
	
	#hit screenshake
	screen_shake.request_screen_shake()
	pass
	
	
func _build_random_spark() -> Node2D:
	
	var spark = Spark.instance()
	spark.position = Utils.rand_point(25, 35)
	spark.rotation = randf() * 360
	spark.scale = Vector2.ONE * rand_range(1.0, 2.0)
	
	return spark
	

func _build_damage_label(hit_connect: HitConnect) -> Node2D:
	
	var label = DamageLabel.instance()
	label.movement *= rand_range(0.75, 1.75)
	var label_node: Label = label.get_node("Label")
	label_node.set("custom_colors/font_color", label_color)
	var stylebox: StyleBoxFlat = label_node.get("custom_styles/normal")
	stylebox.set_border_color(label_color)
	
	return label
	
	
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
	
	
func _add_at_scene_root(node: Node):
	get_tree().get_root().add_child(node)
