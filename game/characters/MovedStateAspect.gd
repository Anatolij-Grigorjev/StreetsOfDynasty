extends State
class_name MovedStateAspect
"""
A state aspect that allows a character to be moved by 
a controlled motion with aspects like facing/speed/etc 
set by the external mover
"""
const TWEEN_DURATION = 0.25

enum Easing {
	GENTLE = 0,
	HALFWAY = 1,
	ALL_IN = 2
}
export(Vector2) var move_impulse: Vector2 = Vector2.ZERO
export(Easing) var move_easing: int = Easing.HALFWAY


onready var move_tween: Tween = _build_move_tween()

var current_impulse: Vector2 = Vector2.ZERO


func enter_state(prev_state: String):
	.enter_state(prev_state)
	if (move_impulse == Vector2.ZERO):
		return
	var transition_easing = _get_move_easing_tween_props()
	#tween interpolates velocity instead of moving entity directly
	#this leaves control over when that velocity is used
	move_tween.interpolate_property(
		self, 'current_impulse', 
		move_impulse * 1 / TWEEN_DURATION, Vector2.ZERO,
		TWEEN_DURATION, transition_easing[0], transition_easing[1]
	)
	move_tween.start()
	

func process_state(delta: float):
	.process_state(delta)
	if (current_impulse != Vector2.ZERO):
		entity.do_movement_collide(current_impulse * delta)


func exit_state(next_state: String):
	.exit_state(next_state)
	move_tween.stop_all()
	move_tween.remove_all()
	current_impulse = Vector2.ZERO


func _build_move_tween() -> Tween:
	var tween = Tween.new()
	add_child(tween)
	return tween
	
	
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
