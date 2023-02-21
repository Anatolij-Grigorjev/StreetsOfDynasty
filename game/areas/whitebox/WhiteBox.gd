extends Node2D
"""
Scene controls for debug convenience
"""

const MudManScn = preload("res://characters/Mudman/MudmanCharacterMain.tscn")

onready var enemy_spawm_pos = $YSort/EnemySpawn


func _process(delta):
	if Input.is_action_just_pressed("debug2"):
		var mudman = MudManScn.instance()
		enemy_spawm_pos.get_parent().add_child_below_node(enemy_spawm_pos, mudman)
		mudman.global_position = enemy_spawm_pos.global_position
