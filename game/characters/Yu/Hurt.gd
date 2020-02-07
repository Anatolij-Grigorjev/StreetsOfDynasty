extends State
"""
State in case the character was hurt with an attack. 
Convulse in pain and later recover
"""
export(float) var hurt_duration: float = 1.0

onready var hurt_time = $Timer
var is_hurting: bool = false


func _ready():
	._ready()
	hurt_time.wait_time = hurt_duration
	hurt_time.connect("timeout", self, "_on_hurt_time_end")


func process_state(delta: float):
	pass
	
	
func enter_state(prev_state: String):
	is_hurting = true
	hurt_time.start()
	entity.anim.play("hurt_low")
	fsm.hitboxes.switch_to_area("HurtLow")
	
	
func exit_state(next_state: String):
	entity.is_hurting = false
	

func _on_hurt_time_end():
	is_hurting = false
	pass
