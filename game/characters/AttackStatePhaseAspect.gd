extends State
class_name AttackStatePhaseAspect
"""
This state aspect is intended to use for attack states
this will follow singlas from attackbox timeline and set the 
correct phase based on those changes
"""
enum AttackPhase {
	UNKNOWN = -1,
	WIND_UP = 0,
	HIT = 1,
	WIND_DOWN = 2
}


export(String) var group_id: String = ""


onready var attack_state: FiniteState = get_parent()
var timeline: AreaGroupTimeline
var attack_phase: int = AttackPhase.UNKNOWN


func _ready():
	call_deferred("_connect_signals")
	attack_phase = AttackPhase.WIND_UP
	
	
func _connect_signals():
	timeline = attack_state.attackbox_areas_timeline
	timeline.connect("group_timeline_started", self, "_attackbox_timeline_group_timeline_started")
	timeline.connect("group_timeline_finished", self, "_attackbox_timeline_group_timeline_finished")


func _attackbox_timeline_group_timeline_started(group_id: String, first_area_name: String):
	attack_phase = AttackPhase.HIT


func _attackbox_timeline_group_timeline_finished(group_id: String, last_area_name: String):
	attack_phase = AttackPhase.WIND_DOWN
