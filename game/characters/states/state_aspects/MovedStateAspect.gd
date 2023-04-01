extends State
class_name MovedStateAspect
"""
A state aspect that allows a character to be moved by 
a controlled motion with aspects like facing/speed/etc 
set by the external mover
By default this moves the entire entity, can move part like the rig
via custom node path
"""


"""
The total movement impulse that this aspect will communicate
to entity via dedicated FSM mover tween
"""
export(Vector2) var move_impulse: Vector2 = Vector2.ZERO
"""
Amount of time there should be movement in seconds
"""
export(float) var move_duration: float = 0.25
"""
Amount of time to pass before the movement tween is invoked
"""
export(float) var move_delay: float = 0.0
"""
make this aspect use the provided impulse once before requiring
manual resets
"""
export(bool) var one_shot: bool = true


var move_tween: Tween

var current_impulse: Vector2 = Vector2.ZERO


func _ready():
	call_deferred("_set_move_tween")


func enter_state(prev_state: String):
	.enter_state(prev_state)
	Debug.log_info("move impulse: %s", [move_impulse])
	if (move_impulse == Vector2.ZERO):
		return
	#wait for delay to pass before movement
	if (move_delay != 0.0):
		yield(get_tree().create_timer(move_delay), "timeout")
	#tween interpolates velocity instead of moving entity directly
	#this leaves control over when that velocity is used

	move_tween.interpolate_property(
		self, 'current_impulse', 
		move_impulse, Vector2.ZERO,
		move_duration, Tween.TRANS_EXPO, Tween.EASE_IN
	)
	move_tween.start()
	

func process_state(delta: float):
	.process_state(delta)
	if (current_impulse != Vector2.ZERO):
		entity.do_movement_collide(current_impulse)
		
		

func exit_state(next_state: String):
	.exit_state(next_state)
	_stop_all_movement()


func _set_move_tween() -> Tween:
	var tween: Tween = fsm.get_node('StatesTween') as Tween
	if (not tween):
		tween = Tween.new()
		tween.name = 'StatesTween'
		fsm.add_child(tween)
	move_tween = tween
	return move_tween
	

func _stop_all_movement():
	move_tween.stop_all()
	move_tween.remove_all()
	if (one_shot):
		move_impulse = Vector2.ZERO
