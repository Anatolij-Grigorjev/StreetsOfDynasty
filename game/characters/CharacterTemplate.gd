extends KinematicBody2D
class_name CharacterTemplate
"""
Base class for game characters. 
Supports having hitboxes and attackboxes, receiving messages about
damage (foreign attackbox contact on own hitbox), sets move speed
"""
signal damage_received(damage, health, total_health)


export(Vector2) var move_speed: Vector2 = Vector2(4 * 64, 2 * 64)
export(Vector2) var sprite_size: Vector2 = Vector2.ZERO
export(float) var total_health: float = 150
var velocity = Vector2()
var facing: int = 1 setget set_facing
var health := total_health
var invincibility := false


onready var fsm: StateMachine = $FSM
onready var body: Node2D = $Body
onready var hitboxes: AreaGroup = $Body/HitboxGroup
onready var attackboxes: AreaGroup = $Body/AttackboxGroup
onready var catch_point: Position2D = $Body/CatchPoint
onready var caught_point: Position2D = $Body/CaughtPoint


var is_hurting = false
var is_caught = false setget _set_caught
var catching_hitbox = null


func _ready() -> void:
	
	fsm.connect("state_changed", self, "_on_FSM_state_changed")
	for hitbox in hitboxes.get_children():
		var typed_hitbox: Hitbox = hitbox as Hitbox
		if (is_instance_valid(typed_hitbox)):
			typed_hitbox.connect("hitbox_hit", self, "_on_hitbox_hit")
			typed_hitbox.connect("hitbox_catch", self, "_on_hitbox_catch")
	
	
func _process(delta: float) -> void:
	pass
	
	
func set_facing(new_facing: int):
	facing = new_facing
	body.scale.x = facing
	

"""
1-arg movement method for use in action tweens. 
This makes sure action tweens move character via velocity
and dont ignore kinematic collisions
"""
func do_movement_collide(velocity: Vector2):
	move_and_collide(velocity)
	

"""
1-arg movement method for use in action tweens. 
This makes sure action tweens move character via velocity
and dont ignore kinematic collisions
"""
func do_movement_slide(velocity: Vector2):
	move_and_slide(velocity, Vector2.UP)
	
	
func _on_hitbox_hit(hit_connect: HitConnect):
	#character level indicator if a hurt-state is happening
	#gets reset when a state with a child HurtStateAspect exits
	is_hurting = true
	_handle_receive_damage(hit_connect)
	_handle_hit_displacement(hit_connect.attackbox, hit_connect.attack_facing)
	
	
func _on_hitbox_catch(enemy_hitbox: Area2D):
	Debug.LOG.info("Catching %s", [enemy_hitbox])
	catching_hitbox = enemy_hitbox
	
	
	
func _handle_hit_displacement(attackbox: AttackBox, attack_facing: int):
	if (attackbox.target_move != Vector2.ZERO):
		print(
			"target_move: %s, attacker facing: %s, target facing: %s" % 
			[attackbox.target_move, attackbox.owner.facing, facing]
		)
		var displacement = attackbox.target_move * attack_facing
		fsm.hurt_move = displacement
	
	
func _on_FSM_state_changed(old_state: String, new_state: String):
	pass
	

func _handle_receive_damage(hit_connect: HitConnect):
	var damage_taken = hit_connect.attack_damage
	health = clamp(health - damage_taken, 0.0, total_health)
	Debug.LOG.info("{} Received {} damage, health is {}", [
		self, damage_taken, health
	])
	emit_signal("damage_received", damage_taken, health, total_health)
	
	
func _set_caught(got_caught: bool):
	is_caught = got_caught
	

func set_post_caught_state(post_caught_state: String):
	fsm.set_post_caught_state(post_caught_state)
