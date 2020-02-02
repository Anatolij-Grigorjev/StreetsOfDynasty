extends KinematicBody2D
class_name CharacterTemplate


export(Vector2) var move_speed: Vector2 = Vector2(4 * 64, 2 * 64)
var velocity = Vector2()


onready var anim: AnimationPlayer = $Body/CharacterRig/AnimationPlayer
onready var fsm: StateMachine = $FSM

func _ready() -> void:
	pass 
	
	
func _process(delta: float) -> void:
	pass
