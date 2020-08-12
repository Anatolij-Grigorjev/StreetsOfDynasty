extends KinematicBody2D
class_name CharacterTemplate
"""
Base class for game characters. 
Supports having hitboxes and attackboxes, receiving messages about
damage (foreign attackbox contact on own hitbox), sets move speed
"""
enum VertMovePhases {
	LIFT, DROP, NONE
}

signal got_hit(hit_connect)
signal landed_hit(hit_connect)
signal damage_received(damage, remaining_health, total_health)
signal stability_reduced(prev_stability, current_stability, total_stability)
signal got_caught(catcher)
signal got_released()
signal caught_character(caught)
signal moved_to_catching_pos(caught_character)
signal rig_position_corrected
signal died


export(Vector2) var move_speed: Vector2 = Vector2(4 * 64, 2 * 64)
export(Vector2) var sprite_size: Vector2 = Vector2.ZERO
export(float) var total_health: float = 150
"""
points of upwards stability. with less than some % the character 
will go to hurting state when the hit is received (rapid recovery), 
with the points expired the character will fall (recovering all)
"""
export(float) var total_stability: float = 100


var velocity = Vector2()
var facing: int = 1 setget set_facing
var health : float
var stability : float
var invincibility := false

var rig_vertical_displacement: bool = false
var rig_neutral_poistion: Vector2 = Vector2.ZERO

onready var fsm: CharacterStateMachineTemplate = $FSM
onready var body: Node2D = $Body
onready var rig: Node2D = _get_rig_node()
onready var hitboxes: AreaGroup = rig.get_node('HitboxGroup')
onready var attackboxes: AreaGroup = rig.get_node('AttackboxGroup')
onready var catch_point: Position2D = $Body/CatchPoint
onready var caught_point: Position2D = $Body/CaughtPoint


var displacement_up_angle: float = 0.0
var displacement_speed: Vector2 = Vector2.ZERO
var max_displacement: Vector2 = Vector2.ZERO
var elapsed_displacement_time: float = 0.0
var current_horiz_displacement: float = 0.0
var vert_move_phase: int = VertMovePhases.NONE


func _ready() -> void:
	health = total_health
	stability = total_stability
	
	fsm.connect("state_changed", self, "_on_FSM_state_changed")
	connect("rig_position_corrected", fsm, "_on_Character_rig_position_corrected")
	
	for hitbox in hitboxes.get_children():
		if (hitbox as Hitbox):
			hitbox.connect("hitbox_hit", self, "_on_hitbox_hit")
			
	rig_neutral_poistion = rig.position
	
	
func _process(delta: float) -> void:
	_process_stability_recovery(delta)
	elapsed_displacement_time += delta
	_correct_rig_position(delta)
	_process_horizontal_movement(delta)
	
	
func _process_stability_recovery(delta: float):
	if (stability < total_stability):
		var recovery_this_frame := _get_stability_recovery_per_sec() * delta
		stability = clamp(stability + recovery_this_frame, 0.0, total_stability)
		
		
func _correct_rig_position(delta: float):
	if (rig_vertical_displacement):
		var thrust_up = -1.0
		var pull_down = -sign(thrust_up) * abs(Utils.sqr(elapsed_displacement_time) * C.GRAVITY / 2)
		if (rig.position.y > max_displacement.y and vert_move_phase == VertMovePhases.LIFT):
			thrust_up = (displacement_speed.y * elapsed_displacement_time * sin(displacement_up_angle))
		else:
			vert_move_phase = VertMovePhases.DROP
		print("position=%s|up=%s|down=%s" % [rig.position.y, thrust_up, pull_down])
		rig.position.y += thrust_up + pull_down
		if (rig.position.y > rig_neutral_poistion.y and abs(thrust_up) < abs(pull_down)):
			rig.position = rig_neutral_poistion
			rig_vertical_displacement = false
			#landed fall means end of movement
			elapsed_displacement_time = 0.0
			vert_move_phase = VertMovePhases.NONE
			emit_signal("rig_position_corrected")
			
			
func _process_horizontal_movement(delta: float):
	if (current_horiz_displacement < max_displacement.x):
		var horizontal_displacement = displacement_speed.x * elapsed_displacement_time
		current_horiz_displacement += horizontal_displacement
		print("position=%s|move=%s" % [global_position.x, horizontal_displacement])
		do_movement_collide(Vector2(horizontal_displacement, 0.0))
	
	
func _get_stability_recovery_per_sec() -> float:
	breakpoint #override me
	return 0.0
	
	
func set_facing(new_facing: int):
	facing = new_facing
	body.scale.x = facing
	

"""
1-arg movement method for use in action tweens. 
This makes sure action tweens move character via velocity
and dont ignore kinematic collisions
"""
func do_movement_collide(velocity: Vector2) -> KinematicCollision2D:
	return move_and_collide(velocity)
	

"""
1-arg movement method for use in action tweens. 
This makes sure action tweens move character via velocity
and dont ignore kinematic collisions
"""
func do_movement_slide(velocity: Vector2) -> Vector2:
	return move_and_slide(velocity, Vector2.UP)
	
	
"""
Move the character rig according to the impulse without 
moving actual character tree position
"""
func lift_rig_impulse(impulse: Vector2):
	Debug.log_info("Character sent up with impulse %s", [impulse])
	rig.position += impulse
	
	
func _on_hitbox_hit(hit_connect: HitConnect):
	emit_signal("got_hit", hit_connect)
	
	var prev_stability = stability
	_reduce_stability(hit_connect)
	emit_signal("stability_reduced", prev_stability, stability, total_stability)
	
	_receive_damage(hit_connect)
	emit_signal("damage_received", hit_connect.attack_damage, health, total_health)
	
	var displacement = _calc_hit_displacement(hit_connect.attackbox, hit_connect.attack_facing)
	displacement_speed = displacement
	max_displacement = displacement
	elapsed_displacement_time = 0.0
	current_horiz_displacement = 0.0
	if (displacement.y):
		rig_neutral_poistion = rig.position
		displacement_up_angle = abs(atan(displacement.y / max(displacement.x, 1.0)))
		rig_vertical_displacement = true
		vert_move_phase = VertMovePhases.LIFT
	else:
		vert_move_phase = VertMovePhases.NONE
		displacement_up_angle = 0.0
		rig_vertical_displacement = false
	print(
		""" 
		target_move impulse: %s, 
		target displacement: %s, 
		attacker facing: %s, 
		target facing: %s,
		displacement_up_angle: %s,
		displacement_speed: %s,
		displacement_max: %s
		""" % 
			[
				hit_connect.attackbox.target_move, 
				displacement, 
				Utils.get_areagroup_area_owner(hit_connect.attackbox).facing, 
				facing,
				displacement_up_angle,
				displacement_speed,
				max_displacement
			]
	)
	
	
	
func _calc_hit_displacement(attackbox: AttackBox, attack_facing: int):
	if (attackbox.target_move != Vector2.ZERO):
		#we assume the supplies 'target_move' is an impulse
		#impulse is change in velocity * mass
		#mass is hit resistance (stability) so we get change in velocity by division
		var stability_coef = max(stability / total_stability, 0.1)
		#highest possible displacement impulse is twice the attack velocity
		var velocity = _get_max_allowed_velocity(attackbox.target_move, stability_coef)
		var displacement = Vector2(velocity.x * attack_facing, velocity.y)
		return displacement
	else:
		return Vector2.ZERO
		
		
func _reduce_stability(hit_connect: HitConnect):
	stability = clamp(stability - hit_connect.attack_disruption, 0, total_stability)
	

func _receive_damage(hit_connect: HitConnect):
	var damage_taken = hit_connect.attack_damage
	health = clamp(health - damage_taken, 0.0, total_health)
	Debug.log_info("{} Received {} damage, health is {}", [
		self, damage_taken, health
	])


func _get_max_allowed_velocity(target_move: Vector2, stability_coef: float) -> Vector2:
	return target_move * (1 - max(stability_coef, 0.1))


func _on_FSM_state_changed(old_state: String, new_state: String):
	pass
	
	
func _get_rig_node() -> Node2D:
	for node in body.get_children():
		if (node.name.find('CharacterRig') > -1):
			return node
	print("Not found character rig in body nodes! Nodes are: %s" % body.get_children())
	breakpoint
	return null
