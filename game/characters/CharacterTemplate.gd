extends KinematicBody2D
class_name CharacterTemplate
"""
Base class for game characters. 
Supports having hitboxes and attackboxes, receiving messages about
damage (foreign attackbox contact on own hitbox), sets move speed
"""


var Spark = preload("res://characters/spritefx/Spark.tscn")

export(Vector2) var move_speed: Vector2 = Vector2(4 * 64, 2 * 64)
var velocity = Vector2()


onready var fsm: StateMachine = $FSM
onready var hitboxes: AreaGroup = $Body/HitboxGroup
onready var attackboxes: AreaGroup = $Body/AttackboxGroup

var is_hurting = false

func _ready() -> void:
	for hitbox in hitboxes.get_children():
		hitbox.connect("hitbox_hit", self, "_on_hitbox_hit")
	
	
func _process(delta: float) -> void:
	pass
	
	
func _on_hitbox_hit(hitbox: Hitbox, attackbox: AttackBox):
	is_hurting = true
	var spark_instance: Node2D = _build_random_spark(hitbox)
	var damage_type = randi() % 2 #attackbox.damage_type
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
	pass

func _build_random_spark(hitbox: Hitbox) -> Node2D:
	var hitbox_center_position = hitbox.shape.global_position
	var spark = Spark.instance()
	var position = Utils.rand_point(10, 5) + hitbox_center_position
	var rotation = randf() * 360
	get_tree().get_root().add_child(spark)
	spark.global_position = position
	spark.global_rotation_degrees = rotation
	
	return spark
