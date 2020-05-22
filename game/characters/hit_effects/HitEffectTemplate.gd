extends Node2D
class_name HitEffectTemplate
"""
Abstract interface for valid hit effects to use when being invoked
"""

func invoke_hit_fx(hit_connect: HitConnect):
	Debug.LOG.info("perform hit effect!")
	breakpoint
