extends Node2D
class_name HitEffectTemplate
"""
Abstract interface for valid hit effects to use when being invoked
"""

onready var shortname: String = name.substr(0, name.find("HitEffect"))

func _ready():
	Debug.log_info("Initialized effect '{}'", [shortname])


func invoke_hit_fx(hit_connect: HitConnect):
	Debug.log_info("perform hit effect!")
	breakpoint
