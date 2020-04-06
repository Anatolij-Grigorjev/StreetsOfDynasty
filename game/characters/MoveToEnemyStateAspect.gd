extends State
class_name MoveToEnemyStateAspect
"""
This state aspect allows doing raycsts for the duration of a state 
and then moving in the direction of an enemy if hit by a raycast
the actual checking takes place during physics process method
which is enabled on state startup
"""

"""
how much max movement can character do towards enemy
"""
export(float) var max_move := 100.67
"""
how big is the raycasting arc for checking 
(from -radius to + radius)
"""
export(float) var check_enemy_arc_radius := 0.0
"""
How far will the rays check for an enemy horizontally
"""
export(float) var check_enemy_max_distance := 350
"""
How much of the arc radius is handled by 1 ray
The lower the number the more accurate the hits
"""
export(float) var arc_ray_partition_size := 10.5
"""
Mask of layers ray should try collide against
"""
export(int, LAYERS_2D_PHYSICS) var collision_mask := 0


onready var state: PerpetualState = get_parent()


func enter_state(prev_state: String):
	.enter_state(prev_state)
	set_physics_process(true)
	
	
func exit_state(next_state: String):
	.exit_state(next_state)
	set_physics_process(false)


func _physics_process(delta):
	entity.update()
	#get 2d physics space
	var space_state := _get_world_space_state()
	#check raycasts direct/above/below in that order
	var hit_position := _get_raycast_checks_hit_position(space_state)
	#use hit position to move there
	if (_hit_position_valid(hit_position)):
		print("RAYCAST: hit at position %s" % hit_position)
		_move_towards_hit_position(hit_position)
		#disable physics to stop further checking
		set_physics_process(false)
	
	
func _get_world_space_state() -> Physics2DDirectSpaceState:
	return entity.get_world_2d().direct_space_state
	
	
func _get_raycast_checks_hit_position(space_state: Physics2DDirectSpaceState) -> Vector2:
	var hit_direct := _cast_ray_in_front(space_state)
	if (_raycast_hit(hit_direct)):
		return hit_direct.position
	if (check_enemy_arc_radius > 0):
		var hit_above := _cast_rays_above(space_state)
		if (_raycast_hit(hit_above)):
			return hit_above.position
		var hit_below := _cast_rays_below(space_state)
		if (_raycast_hit(hit_below)):
			return hit_below.position
		else:
			return Vector2.ZERO
	else:
		return Vector2.ZERO
	
	
func _hit_position_valid(position: Vector2) -> bool:
	return position != Vector2.ZERO
	
	
func _move_towards_hit_position(hit_position: Vector2):
	var position := entity.global_position as Vector2
	var move_direction := position.direction_to(hit_position)
	var move_amount := min(position.distance_to(hit_position), max_move)
	var move_impulse := move_direction * move_amount
	#move for this much impulse in 0.15 seconds
	state._move_with_state(move_impulse, 0.15)




func _cast_ray_in_front(space_state: Physics2DDirectSpaceState) -> Dictionary:
	var global_position := entity.global_position as Vector2
	return _cast_ray_to(
		space_state, 
		global_position + Vector2(check_enemy_max_distance, 0))
	

func _cast_ray_to(space_state: Physics2DDirectSpaceState, ray_endpoint: Vector2) -> Dictionary:
	entity.draw_q.append(ray_endpoint)
	var server_check = space_state.intersect_ray(
		entity.global_position, 
		ray_endpoint, 
		[entity], collision_mask)
	return server_check if (server_check != null) else {}

	
func _cast_rays_above(space_state: Physics2DDirectSpaceState) -> Dictionary: 
	var global_position := entity.global_position as Vector2
	for pos_y_increment in range(arc_ray_partition_size, check_enemy_arc_radius, arc_ray_partition_size):
		var check := _cast_ray_to(space_state, Vector2(
			global_position.x + check_enemy_max_distance,
			global_position.y + pos_y_increment)
		)
		if (_raycast_hit(check)):
			return check
	return {}
	
	
func _raycast_hit(raycast_result) -> bool:
	return raycast_result != null and (raycast_result as Dictionary).has("position")
	
	
func _cast_rays_below(space_state: Physics2DDirectSpaceState) -> Dictionary: 
	var global_position := entity.global_position as Vector2
	for pos_y_increment in range(-arc_ray_partition_size, -check_enemy_arc_radius, -arc_ray_partition_size):
		var check := _cast_ray_to(space_state, Vector2(
			global_position.x + check_enemy_max_distance,
			global_position.y + pos_y_increment)
		)
		if (_raycast_hit(check)):
			return check
	return {}
