extends KinematicBody2D
class_name CharacterTemplate


export(Vector2) var move_speed: Vector2 = Vector2(4 * 64, 2 * 64)
var velocity = Vector2()



func _ready() -> void:
	pass 
	
	
func _process(delta: float) -> void:
	
	var move_direction = _get_move_direction()
	
	if (move_direction.x != 0):
		$Body.scale.x = sign(move_direction.x)
	
	velocity.x = lerp(velocity.x, move_speed.x * move_direction.x, 0.5)
	velocity.y = lerp(velocity.y, move_speed.y * move_direction.y, 0.75) 
	velocity = move_and_slide(velocity, Vector2.UP)


func _get_move_direction() -> Vector2:
	var move_direction_horiz = -int(Input.is_action_pressed("move_left")) + int(Input.is_action_pressed("move_right"))
	var move_direction_vert = -int(Input.is_action_pressed("move_up")) + int(Input.is_action_pressed("move_down"))
	
	return Vector2(move_direction_horiz, move_direction_vert).normalized()
