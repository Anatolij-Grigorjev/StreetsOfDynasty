extends FiniteState
class_name AttackWithPhasesState
"""
A finite state that is taylored for attacks - 
it has the concept of an attack phase, which is of the C.AttackPhases constants
and can be used to report what part of the attack animation the state is 
currently going through

The state uses signals from the rig attackbox group to determine 
the current phase of the attack.

The phases are mapped as follows:
	
	1. Attack starts in phase WIND_UP
	2. When the attackbox of state name becomes active,
	 the attack moves to HIT
	3. When the attackbox of state name becomes inactive, 
	 the attack moes to WIND_DOWN 
"""

var attack_phase: int
var phase_toggle_patterns: Dictionary = {}


func _ready():
	call_deferred("_connect_signals")
	attack_phase = C.AttackPhase.WIND_UP
	phase_toggle_patterns = _build_default_phase_toggle_patterns()
	

func _connect_signals():
	var attack_area_group = entity.attackboxes as AreaGroup
	attack_area_group.connect("area_toggled", self, "_on_attackbox_group_area_toggled")


func _on_attackbox_group_area_toggled(area_name, enabled):
	if (attack_phase >= C.AttackPhase.WIND_DOWN):
		return
	var next_phase = attack_phase + 1
	var next_phase_pattern = phase_toggle_patterns[next_phase]
	if (_event_matches_pattern(area_name, enabled, next_phase_pattern)):
		attack_phase = next_phase
		
		
func _get_next_attack_phase() -> int:
	return (attack_phase + 1) if attack_phase < C.AttackPhase.WIND_DOWN else 0
	
	
func _event_matches_pattern(event_area_name, event_enabled, pattern_array) -> bool:
	if (pattern_array == null or pattern_array.empty()):
		return false
	return pattern_array[0] == event_area_name and pattern_array[1] == event_enabled
	
	
func _build_default_phase_toggle_patterns() -> Dictionary:
	return {
		C.AttackPhase.HIT: [name, true],
		C.AttackPhase.WIND_DOWN: [name, false]
	}
