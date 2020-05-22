extends HitEffectTemplate
"""
A kind of hit effect that spawns a spark with accompanying damage
label and particles burst
"""
var Spark = preload("res://characters/spritefx/Spark.tscn")
var DamageLabel = preload("res://characters/DamageLabel.tscn")


export(String) var spark_anim: String
export(Color) var label_color: Color


onready var hit_particles: Particles2D = $Particles2D


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
		+ hit_connect.receiver.facing * Utils.rand_point(25.0, 25.0)
	)
	#set_damage requires label in tree
	Utils.add_at_scene_root(self, label)
	label.set_damage(-hit_connect.attack_damage)
	
	#hit particles
	_add_particles(spark.position, hit_connect.attack_facing)
	

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
