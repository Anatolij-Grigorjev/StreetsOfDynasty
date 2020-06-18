extends Node
class_name SpriteColorFlash
"""
This effect can be the child of a Sprite to provide a shader-induced
color flash for a specific duration
"""
var SpriteShaderMaterial = preload("res://characters/MixColorShader.tres")

export(NodePath) var sprite_path = ".."

onready var sprite: Sprite = get_node(sprite_path)
onready var tween: Tween = _create_tween()
onready var material = SpriteShaderMaterial.duplicate(true)

func _ready():
	call_deferred("_register_color_flashers")
	
	
func _do_color_flash(color = Color.blue, total_duration = 0.3, max_blend = 0.8, buildup_slice = 0.7):
	var buildup_time = total_duration * buildup_slice
	material.set_shader_param("modulate", color)
	_set_sprite_material()
	tween.start()
	tween.interpolate_method(
		self, "_set_shader_color_mix",
		0.0, max_blend, 
		buildup_time, 
		Tween.TRANS_EXPO, Tween.EASE_OUT
	)
	yield(tween, "tween_completed")
	tween.interpolate_method(
		self, "_set_shader_color_mix",
		max_blend, 0.0,
		total_duration - buildup_time,
		Tween.TRANS_EXPO, Tween.EASE_OUT
	)
	yield(tween, "tween_completed")
	
	sprite.use_parent_material = true
	

func _set_sprite_material():
	sprite.material = material
	sprite.use_parent_material = false
	
	
func _set_shader_color_mix(mix_value: float):
	material.set_shader_param("mix_coef", mix_value)
	
	
func _create_tween() -> Tween:
	var tween := Tween.new()
	add_child(tween)
	return tween
	

func _register_color_flashers():
	for flash_requestor in get_tree().get_nodes_in_group("color_flashers"):
		flash_requestor.connect("color_flash_requested", self, "_do_color_flash")
