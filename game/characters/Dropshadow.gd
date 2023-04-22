extends Node2D
"""
On-ground shadow that moves with character. 
Gets smaller during jumps
"""

"""
Amoutn of scale removed from shadow sprite per 100 pixels of lift
For example at 0.2 the shadow will turn invisible with 500 pixels lift
"""
const LIFTED_SIZE_REDUCTION = 0.2

onready var character = get_parent() as CharacterTemplate
onready var shadow = $Sprite

func _ready():
	character.connect("changed_facing", self, "_character_changed_facing")


func _process(delta):
	var scale_reduce_amount = (character.rig_neutral_position.y - character.rig.position.y) / 100 * LIFTED_SIZE_REDUCTION
	var next_scale = 1.0 - scale_reduce_amount
	shadow.scale = Vector2.ONE * next_scale
	

func _character_changed_facing(new_facing: int):
	self.scale.x = abs(self.scale.x) * sign(new_facing)
