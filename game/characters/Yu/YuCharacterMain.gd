extends CharacterTemplate
"""
Character behavior and nodes specific to Yu
"""


onready var anim: AnimationPlayer = $Body/YuCharacterRig/AnimationPlayer
onready var LOG: Logger = $Logger
onready var current_state_lbl: Label = $CurrentState

var draw_q = []

func _ready():
	fsm.connect("next_attack_input_changed", self, "_on_FSM_next_attack_input_changed")
	

func _on_hitbox_hit(hitbox: Hitbox, attackbox: AttackBox):
	._on_hitbox_hit(hitbox, attackbox)
	LOG.info("{} got hit by {}!", [hitbox, attackbox])
	
	
func _on_FSM_state_changed(old_state: String, new_state: String):
	current_state_lbl.text = new_state
	
	
func _process(delta):
	update()
	
	
func _draw():
	if (not draw_q.empty()):
		for point in draw_q:
			draw_line(global_position, point, Color.red, 15.0)
		draw_q.clear()
	
	
func _on_FSM_next_attack_input_changed(next_attack_input: int):
	var only_state_label_text := _get_no_NXT_label_text()
	if (next_attack_input > 0):
		current_state_lbl.text = "%s (NXT:%s)" % [only_state_label_text, next_attack_input]
		
	
	
func _get_no_NXT_label_text() -> String:
	var current_text: String = current_state_lbl.text
	var prev_mention := current_text.find_last(" (NXT:")
	if (prev_mention >= 0):
		return current_text.substr(0, prev_mention)
	else:
		return current_text
