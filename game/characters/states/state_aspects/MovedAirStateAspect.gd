extends State
class_name MovedAirStateAspect
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

signal vert_move_started(vert_impulse)
signal vert_move_finished()


"""
The total air the aspect should make rig grab
"""
export(float) var total_move_height: float = 0.0
"""
Amount of time there should be movement in seconds
"""
export(float) var move_duration: float = 0.25
"""
Amount of time to pass before the movement tween is invoked
"""
export(float) var move_delay: float = 0.0
"""
If true the aspect will keep impulse provided during previous
invocation. 
This way an impulse set via inspector can be applied every invocation
"""
export(bool) var preserve_impulse: bool = false

export(Easing) var move_easing: int = Easing.HALFWAY


var move_tween: Tween

var vert_current_impulse: float = 0.0

"""
flag that THIS aspect is the one that started the common tween
not to consume signals for others
"""
var tweens_running: int = 0


func _ready():
	call_deferred("_set_move_tween")
	call_deferred("_set_vert_move_entity_signals")


func enter_state(prev_state: String):
	.enter_state(prev_state)
	Debug.log_info("vert move impulse: %s", [total_move_height])
	if (total_move_height == 0.0):
		return
	#wait for delay to pass before movement
	if (move_delay != 0.0):
		yield(get_tree().create_timer(move_delay), "timeout")
	#reset tweens semaphore
	tweens_running = 0
	var transition_easing = _get_move_easing_tween_props()
	#tween interpolates velocity instead of moving entity directly
	#this leaves control over when that velocity is used
	move_tween.interpolate_property(
		self, 'vert_current_impulse',
		total_move_height, 0.0,
		move_duration, transition_easing[0], transition_easing[1]
	)
	tweens_running += 1
	emit_signal("vert_move_started", total_move_height)
	move_tween.start()
	
	

func process_state(delta: float):
	.process_state(delta)
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
	#there was ongoing vertical movement
	if (abs(total_move_height) > 0.0):
		emit_signal("vert_move_finished")
	move_tween.remove_all()
	vert_current_impulse = 0.0
	if (not preserve_impulse):
		total_move_height = 0.0
	
	
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


func _on_StatesTween_tween_completed(receiver: Object, key: NodePath):
	#if no tweens running in this instance we ignore signal
	if (tweens_running == 0):
		return
	#reduce num of locked tweens
	tweens_running -= 1
	emit_signal("vert_move_finished")
			
			
func _set_vert_move_entity_signals():
	connect("vert_move_started", entity, "_on_MovedAirAspect_vert_move_started")
	connect("vert_move_finished", entity, "_on_MovedAirAspect_vert_move_finished")
