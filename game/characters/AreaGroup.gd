extends Node2D
class_name AreaGroup
"""
Utility to switch to a specific active area in a list of areas
If areas are put as children of this node they can be managed
using the methods
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
	_disable_all_areas()
	_enable_area(area_name)
	self.active_area = area_name


func _disable_all_areas() -> void:
	for area_name in all_areas:
		_get_area_shape(all_areas[area_name]).disabled = true


func _enable_area(area_name: String) -> void:
	if (all_areas.has(area_name)):
		_get_area_shape(all_areas[area_name]).disabled = false
		
		
func _get_area_shape(area: Area2D) -> CollisionObject2D:
	return area.get_child(0) as CollisionObject2D