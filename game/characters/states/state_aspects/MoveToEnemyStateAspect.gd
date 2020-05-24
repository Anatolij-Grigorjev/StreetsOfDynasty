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
export(float) var check_enemy_max_distance := 550
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

var rays_array: Node2D
var direct_ray: RayCast2D

func _ready():
	call_deferred("_build_rays_arc")


func _build_rays_arc():
	#create container
	rays_array = Node2D.new()
	rays_array.name = "MoveToEnemyAspectRays"
	#add tree to character
	entity.body.add_child(rays_array)
	rays_array.position = Vector2(0, -entity.sprite_size.y / 2)
	
	#add rays
	direct_ray = _build_raycast_to(Vector2(check_enemy_max_distance, 0))
	rays_array.add_child(direct_ray)
	for pos_y_increment in range(arc_ray_partition_size, check_enemy_arc_radius, arc_ray_partition_size):
		var ray_above = _build_raycast_to(Vector2(check_enemy_max_distance, pos_y_increment))
		rays_array.add_child(ray_above)
	for pos_y_increment in range(-arc_ray_partition_size, -check_enemy_arc_radius, -arc_ray_partition_size):
		var ray_below = _build_raycast_to(Vector2(check_enemy_max_distance, pos_y_increment))
		rays_array.add_child(ray_below)


func _build_raycast_to(destination: Vector2) -> RayCast2D:
	var ray = RayCast2D.new()
	ray.collide_with_areas = true
	ray.collide_with_bodies = false
	ray.cast_to = destination
	ray.collision_mask = collision_mask
	
	return ray


func enter_state(prev_state: String):
	.enter_state(prev_state)
	#enable rays array
	for ray in rays_array.get_children():
		ray.enabled = true
	set_process(true)
	
	
func exit_state(next_state: String):
	.exit_state(next_state)
	#disable rays array
	for ray in rays_array.get_children():
		ray.enabled = false
	set_process(false)


func _process(delta):

	#check raycasts direct/above/below in that order
	var hit_dict := _get_raycast_checks_hit_dict()
	#use hit position to move there
	if (_is_hit_position_valid(hit_dict)):
		print("RAYCAST: got valid hit info %s" % hit_dict)
		_move_towards_hit_position(hit_dict.collider.global_position)
		#disable physics to stop further checking
		set_process(false)
	
	
func _get_raycast_checks_hit_dict() -> Dictionary:
	var hit_direct := _check_ray(direct_ray)
	if (_raycast_hit(hit_direct)):
		return hit_direct
		
	if (check_enemy_arc_radius > 0):
		for ray in rays_array.get_children():
			var hit := _check_ray(ray)
			if (_raycast_hit(hit)):
				return hit
				
		return {}
	else:
		return {}
	
	
func _is_hit_position_valid(hit_dict: Dictionary) -> bool:
	return hit_dict.has("hit") && hit_dict.hit
	
	
func _move_towards_hit_position(hit_position: Vector2):
	var position := entity.global_position as Vector2
	var moved_position := position.move_toward(hit_position, max_move)
	print("moving from %s to %s up to %s" % [position, hit_position, moved_position])
	#move for this much impulse in 0.15 seconds
	state._move_with_state(
		(moved_position - position), 
		0.15,
		0.0,
		C.CharacterMoveType.MOVE_COLLIDE
	)


func _check_ray_in_front() -> Dictionary:
	return _check_ray(direct_ray)
	

func _check_ray(ray: RayCast2D) -> Dictionary:
	return {
		'hit': ray.is_colliding(),
		'position': ray.get_collision_point(),
		'collider': ray.get_collider(),
		'collider_shape_rid': ray.get_collider_shape()
	}
	
	
func _raycast_hit(raycast_result: Dictionary) -> bool:
	return raycast_result.hit
