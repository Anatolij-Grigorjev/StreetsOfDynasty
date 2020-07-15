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

signal fall_started(vert_impulse)

"""
The total movement impulse that this aspect will communicate
to entity via dedicated FSM mover tween
"""
export(float) var horiz_move_impulse: float = 0.0
export(float) var vert_move_impulse: float = 0.0
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
"""
If true the aspect will keep the rig lifted when the impulse provides
a negative vertical velocity
"""
export(bool) var keep_in_air: bool = false
export(Easing) var move_easing: int = Easing.HALFWAY


var move_tween: Tween

var horiz_current_impulse: float = 0.0
var vert_current_impulse: float = 0.0

"""
flag that THIS aspect is the one that started the common tween
not to consume signals for others
"""
var tween_starter: bool = false


func _ready():
	call_deferred("_set_move_tween")


func enter_state(prev_state: String):
	.enter_state(prev_state)
	var move_impulse = get_joined_impulse()
	Debug.log_info("move impulse: %s", [move_impulse])
	if (move_impulse == Vector2.ZERO):
		return
	#a tween will start now
	tween_starter = true
	var transition_easing = _get_move_easing_tween_props()
	#tween interpolates velocity instead of moving entity directly
	#this leaves control over when that velocity is used
	if (horiz_move_impulse != 0.0):
		move_tween.interpolate_property(
			self, 'horiz_current_impulse', 
			horiz_move_impulse * 1 / move_duration, 0.0,
			move_duration, transition_easing[0], transition_easing[1]
		)
	if (vert_move_impulse != 0.0):
		move_tween.interpolate_property(
			self, 'vert_current_impulse',
			vert_move_impulse * 1 / move_duration, 0.0,
			move_duration, transition_easing[0], transition_easing[1]
		)
		entity.rig_lifting = true
		emit_signal("fall_started", vert_move_impulse)
	move_tween.start()
	
	

func process_state(delta: float):
	.process_state(delta)
	if (horiz_current_impulse != 0.0):
		entity.do_movement_collide(Vector2(horiz_current_impulse, 0.0) * delta)
	if (vert_current_impulse != 0.0):
		entity.lift_rig_impulse(Vector2(0, vert_current_impulse) * delta)
		
		

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
	move_tween.connect("tween_completed", self, "_on_StatesTween_tween_completed")
	return move_tween
	

func _stop_all_movement():
	move_tween.stop_all()
	move_tween.remove_all()
	horiz_current_impulse = 0.0
	vert_current_impulse = 0.0
	if (not preserve_impulse):
		horiz_move_impulse = 0.0
		vert_move_impulse = 0.0
	
	
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
			
			
func set_move_impulses(impulse: Vector2):
	horiz_move_impulse = impulse.x
	vert_move_impulse = impulse.y
	

func get_joined_impulse() -> Vector2:
	return Vector2(horiz_move_impulse, vert_move_impulse)


func _on_StatesTween_tween_completed(receiver: Object, key: NodePath):
	#guard others consuming this signal
	if (not tween_starter):
		return
	#reset tween starting state to not consume more signals
	tween_starter = false
	var path_string = key.get_concatenated_subnames()
	if (not keep_in_air):
		if (path_string.find('vert_current_impulse') > -1):
			entity.rig_lifting = false
