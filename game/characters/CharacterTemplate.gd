extends KinematicBody2D
class_name CharacterTemplate
"""
Base class for game characters. 
Supports having hitboxes and attackboxes, receiving messages about
damage (foreign attackbox contact on own hitbox), sets move speed
"""
export(Vector2) var move_speed: Vector2 = Vector2(4 * 64, 2 * 64)
export(Vector2) var sprite_size: Vector2 = Vector2.ZERO
var velocity = Vector2()
var facing: int = 1


onready var fsm: StateMachine = $FSM
onready var body: Node2D = $Body
onready var hitboxes: AreaGroup = $Body/HitboxGroup
onready var attackboxes: AreaGroup = $Body/AttackboxGroup


var is_hurting = false


func _ready() -> void:
	fsm.connect("state_changed", self, "_on_FSM_state_changed")
	for hitbox in hitboxes.get_children():
		var typed_hitbox: Hitbox = hitbox as Hitbox
		if (is_instance_valid(typed_hitbox)):
			typed_hitbox.connect("hitbox_hit", self, "_on_hitbox_hit")
	
	
func _process(delta: float) -> void:
	pass
	

func do_movement_collide(velocity: Vector2):
	move_and_collide(velocity)
	

"""
1-arg movement method for use in action tweens. 
This makes sure action tweens move character via velocity
and dont ignore kinematic collisions
"""
func do_movement_slide(velocity: Vector2):
	move_and_slide(velocity, Vector2.UP)
	
	
func _on_hitbox_hit(hitbox: Hitbox, attackbox: AttackBox):
	#character level indicator if a hurt-state is happening
	#gets reset when a state with a child HurtStateAspect exits
	is_hurting = true
	_handle_hit_displacement(attackbox)
	
	
	
func _handle_hit_displacement(attackbox: AttackBox):
	if (attackbox.target_move != Vector2.ZERO):
		print(
			"target_move: %s, attacker facing: %s, target facing: %s" % 
			[attackbox.target_move, attackbox.owner.facing, facing]
		)
		var displacement = attackbox.target_move * attackbox.owner.facing
		fsm.hurt_move = displacement
	
	
func _on_FSM_state_changed(old_state: String, new_state: String):
	pass
