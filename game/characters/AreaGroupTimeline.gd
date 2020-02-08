extends Node2D
class_name AreaGroupTimeline
"""
AreaGroup extension that enables various area group 
areas during a fixed timeline. 
Can be reset and stepped through manually
"""

onready var area_group: AreaGroup = get_parent()
"""
Timeline of timebox activations during this attack.
A timeline item can be described as the object:
	{
		time: 0.34, <-- point to do action
		enable: false, <-- flag to disable or enable the area
		area: "A1" <-- name of area to feed into area group
	}
"""
export(Array, Dictionary) var areas_timeline := []
var iteration_time: float = 0.0
var timeline_idx: int = 0


func _ready():
	set_process(false)
	set_physics_process(false)
	

func reset():
	timeline_idx = 0
	iteration_time = 0.0
	
	
func process_timeline(delta: float):
	if (timeline_idx >= areas_timeline.size()):
		return
	while (
		timeline_idx < areas_timeline.size()
		and areas_timeline[timeline_idx].time < iteration_time
	):
		_apply_timeline_item(areas_timeline[timeline_idx])
		timeline_idx += 1
		
	iteration_time += delta
	

func _apply_timeline_item(timeline_item: Dictionary):
	if (timeline_item.enable):
		area_group.enable_area(timeline_item.area)
	else:
		area_group.disable_area(timeline_item.area)
