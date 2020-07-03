extends State
class_name MovedStateAspect
"""
A state aspect that allows a character to be moved by 
a controlled motion with aspects like facing/speed/etc 
set by the external mover
"""
enum Easing {
	GENTLE = 0,
	HALFWAY = 1,
	ALL_IN = 2
}

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
If true the aspect will keep impulse provided during previous
invocation. 
This way any state with this aspect will keep moving 
even without new explicit impulse
"""
export(bool) var preserve_impulse: bool = false
export(Easing) var move_easing: int = Easing.HALFWAY


var move_tween: Tween

var current_impulse: Vector2 = Vector2.ZERO


func _ready():
	call_deferred("_set_move_tween")


func enter_state(prev_state: String):
	.enter_state(prev_state)
	Debug.log_info("move impulse: %s", [move_impulse])
	if (move_impulse == Vector2.ZERO):
		return
	var transition_easing = _get_move_easing_tween_props()
	#tween interpolates velocity instead of moving entity directly
	#this leaves control over when that velocity is used
	move_tween.interpolate_property(
		self, 'current_impulse', 
		move_impulse * 1 / move_duration, Vector2.ZERO,
		move_duration, transition_easing[0], transition_easing[1]
	)
	move_tween.start()
	

func process_state(delta: float):
	.process_state(delta)
	if (current_impulse != Vector2.ZERO):
		entity.do_movement_collide(current_impulse * delta)


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
	current_impulse = Vector2.ZERO
	if (not preserve_impulse):
		move_impulse = Vector2.ZERO
	
	
func _get_move_easing_tween_props() -> Array:
	match(move_easing):
		Easing.HALFWAY:
			return [Tween.TRANS_LINEAR, Tween.EASE_OUT_IN]
		#easings are counter-intuitive because tween substracts
		#value instead of accumulating it
		Easing.GENTLE:
			return [Tween.TRANS_EXPO, Tween.EASE_OUT]
		Easing.ALL_IN:
			return [Tween.TRANS_EXPO, Tween.EASE_IN]
		_:
			breakpoint
			return [Tween.TRANS_ELASTIC, Tween.EASE_IN_OUT]
