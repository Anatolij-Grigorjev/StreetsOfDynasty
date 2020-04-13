extends State
class_name AttackStatePhaseAspect
"""
This state aspect is intended to use for attack states
this will follow singlas from attackbox timeline and set the 
correct phase based on those changes
"""


export(String) var group_id: String = ""


onready var attack_state: FiniteState = get_parent()
var timeline: AreaGroupTimeline
var attack_phase: int


func _ready():
	call_deferred("_connect_signals")
	attack_phase = C.AttackPhase.WIND_UP
	
	
func _connect_signals():
	timeline = attack_state.attackbox_areas_timeline
	timeline.connect("group_timeline_area_changed", self, "_attackbox_timeline_group_timeline_changed")


func _attackbox_timeline_group_timeline_changed(group_id: String, prev_area_name, next_area_name):
	if (prev_area_name and not next_area_name):
		attack_phase = C.AttackPhase.WIND_DOWN
	elif (not prev_area_name and next_area_name):
		attack_phase = C.AttackPhase.HIT
