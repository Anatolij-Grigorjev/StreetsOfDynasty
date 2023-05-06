extends Node2D

onready var anim: AnimationPlayer = $AnimationPlayer

func _ready():
	var death_animations = Array(anim.get_animation_list())
	death_animations.erase("RESET")
	
	anim.play(death_animations[randi() % death_animations.size()])
