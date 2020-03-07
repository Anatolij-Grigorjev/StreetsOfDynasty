extends Node2D
class_name AreaGroupTimeline
"""
AreaGroup extension that enables various area group 
areas during a fixed timeline. 
Can be reset and stepped through manually
Supports concurrent work with multiple timelines within the same group
"""

onready var area_group: AreaGroup = get_parent()
"""
Items of areabox activations during this timeline.
A timeline item can be described as the object:
	{
		time: 0.34, <-- point to do action
		enable: false, <-- flag to disable or enable the area
		area: "A1" <-- name of area to toggle in the parent area group
	}
"""
export(Dictionary) var areas_timelines := {}

#helper vars to loop
var iteration_times: Dictionary = {}
var timelines_idx: Dictionary = {}


func _ready():
	set_process(false)
	set_physics_process(false)
	

func reset(group_id: String):
	timelines_idx[group_id] = 0
	iteration_times[group_id] = 0.0
	

func add_group_timeline(group_id: String, timeline_items: Array):
	areas_timelines[group_id] = timeline_items
	reset(group_id)
	
	
func process_timeline(group_id: String, delta: float):
	var group_timeline_idx = timelines_idx[group_id]
	var group_timeline = areas_timelines[group_id]
	
	if (group_timeline_idx >= group_timeline.size()):
		return
	while (
		group_timeline_idx < group_timeline.size()
		and group_timeline[group_timeline_idx].time < iteration_times[group_id]
	):
		_apply_timeline_item(group_timeline[group_timeline_idx])
		group_timeline_idx += 1
	
	#write values back into maps
	timelines_idx[group_id] = group_timeline_idx
	iteration_times[group_id] += delta
	

func _apply_timeline_item(timeline_item: Dictionary):
	if (timeline_item.enable):
		area_group.enable_area(timeline_item.area)
	else:
		area_group.disable_area(timeline_item.area)
