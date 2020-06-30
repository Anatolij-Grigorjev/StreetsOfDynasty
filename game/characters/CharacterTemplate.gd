extends KinematicBody2D
class_name CharacterTemplate
"""
Base class for game characters. 
Supports having hitboxes and attackboxes, receiving messages about
damage (foreign attackbox contact on own hitbox), sets move speed
"""
signal got_hit(hit_connect)
signal damage_received(damage, remaining_health, total_health)
signal stability_reduced(prev_stability, current_stability, total_stability)
signal hit_displaced(displacement)
signal got_caught(catcher)
signal got_released(post_caught_state)
signal caught_character(caught)
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


onready var fsm: CharacterStateMachineTemplate = $FSM
onready var body: Node2D = $Body
onready var rig: Node2D = _get_rig_node()
onready var hitboxes: AreaGroup = rig.get_node('HitboxGroup')
onready var attackboxes: AreaGroup = rig.get_node('AttackboxGroup')
onready var catch_point: Position2D = $Body/CatchPoint
onready var caught_point: Position2D = $Body/CaughtPoint


func _ready() -> void:
	health = total_health
	stability = total_stability
	
	fsm.connect("state_changed", self, "_on_FSM_state_changed")
	
	for hitbox in hitboxes.get_children():
		if (hitbox as Hitbox):
			hitbox.connect("hitbox_hit", self, "_on_hitbox_hit")
	
	
func _process(delta: float) -> void:
	_process_stability_recovery(delta)
	
	
func _process_stability_recovery(delta: float):
	if (stability < total_stability):
		var recovery_this_frame := _get_stability_recovery_per_sec() * delta
		stability = clamp(stability + recovery_this_frame, 0.0, total_stability)
	
	
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
	
	
func _on_hitbox_hit(hit_connect: HitConnect):
	emit_signal("got_hit", hit_connect)
	
	var prev_stability = stability
	_reduce_stability(hit_connect)
	emit_signal("stability_reduced", prev_stability, stability, total_stability)
	
	_receive_damage(hit_connect)
	emit_signal("damage_received", hit_connect.attack_damage, health, total_health)
	
	var displacement = _calc_hit_displacement(hit_connect.attackbox, hit_connect.attack_facing)
	emit_signal("hit_displaced", displacement)
	
	
	
func _calc_hit_displacement(attackbox: AttackBox, attack_facing: int):
	if (attackbox.target_move != Vector2.ZERO):
		print(
			"target_move: %s, attacker facing: %s, target facing: %s" % 
			[attackbox.target_move, Utils.get_areagroup_area_owner(attackbox).facing, facing]
		)
		var displacement = attackbox.target_move * attack_facing
		return displacement
		
		
func _reduce_stability(hit_connect: HitConnect):
	stability = clamp(stability - hit_connect.attack_disruption, 0, total_stability)
	

func _receive_damage(hit_connect: HitConnect):
	var damage_taken = hit_connect.attack_damage
	health = clamp(health - damage_taken, 0.0, total_health)
	Debug.log_info("{} Received {} damage, health is {}", [
		self, damage_taken, health
	])


func _on_FSM_state_changed(old_state: String, new_state: String):
	pass
	
	
func _get_rig_node() -> Node2D:
	for node in body.get_children():
		if (node.name.find('CharacterRig') > -1):
			return node
	print("Not found character rig in body nodes! Nodes are: %s" % body.get_children())
	breakpoint
	return null
