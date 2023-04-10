extends AttackWithPhasesState



func enter_state(prev_state: String):
	.enter_state(prev_state)
	# performed in script since doesnt trigger by animation player
	yield(get_tree().create_timer(0.29), "timeout")
	start_rig_movement()


func start_rig_movement():
	fsm.fall_finished = false
	entity._start_rig_displacement(Vector2(15 * entity.facing, -300))
