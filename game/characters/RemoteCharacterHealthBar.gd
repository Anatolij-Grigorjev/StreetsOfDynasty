extends "res://characters/HealthBar.gd"
"""
A healthbar variant that can be placed remotely from character it
tracks health of.
This is achieved by a character node reference, which connects
damage signals to self on _ready
"""
export(NodePath) var character_node_path: NodePath

onready var character_node: CharacterTemplate = get_node(character_node_path)


func _ready():
	set_total(character_node.total_health)
	character_node.connect("damage_received", self, "_on_character_damage_received")
	character_node.connect("died", self, "_on_character_died")


func _on_character_died():
	queue_free()
