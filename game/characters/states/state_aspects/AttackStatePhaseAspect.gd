extends State
class_name AttackStatePhaseAspect
"""
This state aspect is intended to use for attack states
this will follow singlas from attackbox timeline and set the 
correct phase based on those changes
"""
export(Array, String) var attack_area_names := []

onready var attack_state: FiniteState = get_parent()
var attack_phase: int


func _ready():
	call_deferred("_connect_signals")
	attack_phase = C.AttackPhase.WIND_UP
	
	
func _connect_signals():
	var attack_area_group = attack_state.entity.attackboxes as AreaGroup
	attack_area_group.connect("area_changed", self, "_on_attackbox_group_area_changed")


func _on_attackbox_group_area_changed(prev_area_name, next_area_name):
	if (
		not (
			attack_area_names.has(prev_area_name) 
			or attack_area_names.has(next_area_name)
		)
	):
		return
	if (prev_area_name and not next_area_name):
		attack_phase = C.AttackPhase.WIND_DOWN
	elif (not prev_area_name and next_area_name):
		attack_phase = C.AttackPhase.HIT
