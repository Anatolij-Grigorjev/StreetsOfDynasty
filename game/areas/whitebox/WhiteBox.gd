extends Node2D
"""
Scene controls for debug convenience
"""

onready var enemy_spawm = $YSort/EnemySpawn


func _process(delta):
	if Input.is_action_just_pressed("debug2"):
		enemy_spawm.spawn()
