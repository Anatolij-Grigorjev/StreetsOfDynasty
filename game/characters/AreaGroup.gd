extends Node2D
class_name AreaGroup
"""
If areas are put as children of this node they can be managed
using this area group node
This group node supports setting one active area or disabling/enabling
specific areas by node name
"""
export(NodePath) var entity_path := NodePath("..")
export(String) var active_area := "" setget switch_to_area


onready var entity := get_node(entity_path)
onready var all_areas := {}


func _ready() -> void:
	for node in get_children():
		if (node is Area2D):
			var area := node as Area2D
			all_areas[area.name] = area

"""
Switch to a specific named area and disable all others
"""
func switch_to_area(area_name: String) -> void:
	disable_all_areas()
	enable_area(area_name)
	active_area = area_name
	

"""
Toggle area node named area_name to visible enabled
"""
func enable_area(area_name: String):
	_toggle_area_enabled(area_name, true)
	

"""
Toggle area node named area_name to invisible disabled
"""
func disable_area(area_name: String):
	_toggle_area_enabled(area_name, false)
		
		
func _toggle_area_enabled(area_name: String, enable: bool) -> void:
	if (all_areas.has(area_name)):
		_get_area_shape(all_areas[area_name]).disabled = not enable
		all_areas[area_name].visible = enable


func disable_all_areas() -> void:
	for area_name in all_areas:
		_get_area_shape(all_areas[area_name]).disabled = true
		all_areas[area_name].visible = false
		
		
func _get_area_shape(area: Area2D) -> CollisionShape2D:
	return area.get_child(0) as CollisionShape2D
