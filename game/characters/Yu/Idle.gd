extends State

onready var hitbox_group: AreaGroup = get_node(@"../../Body/HitboxGroup")

func process_state(delta: float):
	pass
	
	
func enter_state(prev_state: String):
	entity.anim.play("idle")
	hitbox_group.switch_to_area("Idle")
	
	
func exit_state(next_state: String):
	pass 
