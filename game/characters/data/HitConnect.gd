class_name HitConnect
"""
Data holder describing aspects of a connected hit
(that is a hit that resulted in an attackbox touching a hitbox)
"""

var hitbox
var attackbox
var overlap: Rect2
var attacker: Node2D
var receiver: Node2D
var attack_facing: int
var attack_damage_type: int


func _init(hitbox, attackbox):
	self.hitbox = hitbox
	self.attackbox = attackbox
	self.overlap = Utils.get_collision_rects_overlap(hitbox.shape, attackbox.shape)
	self.attacker = attackbox.owner
	self.receiver = hitbox.owner
	self.attack_facing = attacker.facing
	self.attack_damage_type = attackbox.damage_type
