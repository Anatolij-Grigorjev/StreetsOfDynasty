extends Node2D
"""
Label that appears as character takes a hit, 
this thing announces the damage amount and flies away
"""
export(Vector2) var movement: Vector2 = Vector2(50, -50)


onready var label: Label = $Label
onready var tween: Tween = $Tween

func _ready():
	tween.interpolate_property(
		self, 'global_position', 
		null, global_position + movement, 
		0.2, Tween.TRANS_EXPO, Tween.EASE_OUT
	)
	tween.start()
	yield(get_tree().create_timer(1.5), 'timeout')
	queue_free()
	
	
func set_damage(damage: float):
	label.text = "%2.2f" % damage
	
