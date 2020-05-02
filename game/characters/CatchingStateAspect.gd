extends State
class_name CatchingStateAspect
"""
This aspect uses a target CharacterTemplate which is caught by 
owner of this aspect
"""
var caught_character: CharacterTemplate



func process_state(delta: float):
	.process_state(delta)
	
	
func enter_state(prev_state: String):
	.enter_state(prev_state)
	caught_character.is_caught = true
	_align_caught_catch_points()
	
	
func exit_state(next_state: String):
	.exit_state(next_state)
	caught_character.is_caught = false
	
	
func _align_caught_catch_points():
	#make them look at each other
	caught_character.facing = -1 * entity.facing
	yield(get_tree(), "idle_frame")
	
	var caught_pos: Vector2 = caught_character.caught_point.global_position
	var catch_pos: Vector2 = entity.catch_point.global_position
	var directed_move: Vector2 = caught_pos.direction_to(catch_pos) * caught_pos.distance_to(catch_pos)
	caught_character.global_position += directed_move
	#reduce y to catcher
	caught_character.global_position.y = entity.global_position.y
