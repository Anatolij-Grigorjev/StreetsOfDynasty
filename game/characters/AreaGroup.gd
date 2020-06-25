extends Node2D
class_name AreaGroup
"""
If areas are put as children of this node they can be managed
using this area group node
This group node supports setting one active area or disabling/enabling
specific areas by node name
"""
signal area_changed(prev_area_name, next_area_name)

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
	var prev_area = null if active_area.empty() else active_area
	disable_all_areas()
	enable_area(area_name)
	active_area = area_name
	emit_signal("area_changed", prev_area, active_area)
	

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
		
		
func get_enabled_areas() -> Array:
	var enabled_areas := []
	for area_name in all_areas:
		if (all_areas[area_name].visible):
			enabled_areas.append(all_areas[area_name])
	return enabled_areas
		

func _get_area_shape(area: Area2D) -> CollisionShape2D:
	return area.get_child(0) as CollisionShape2D
	
	
func _to_string():
	return "AG[%s](%s)" % [name, all_areas.size()]
