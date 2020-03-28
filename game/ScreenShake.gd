extends Node2D
"""
An action that can be attached to a given Camera2D to perform 
screen shake on-demand
"""
const TRANSITION = Tween.TRANS_SINE
const EASING = Tween.EASE_OUT_IN

var amplitude = 0

onready var camera: Camera2D = get_parent()


func start(duration = 0.2, frequency = 15, amplitude = 10):
	self.amplitude = amplitude
	
	$Duration.wait_time = duration
	$Frequency.wait_time = 1 / float(frequency)
	$Duration.start()
	$Frequency.start()
	
	_new_shake()


func _new_shake():
	var rand_offset = Utils.rand_point(amplitude, amplitude)
	
	$ShakeTween.interpolate_property(
		camera, 'offset', 
		camera.offset, rand_offset, 
		$Frequency.wait_time, TRANSITION, EASING
	)
	$ShakeTween.start()


func _reset():
	$ShakeTween.interpolate_property(
		camera, 'offset', 
		camera.offset, Vector2(), 
		$Frequency.wait_time, TRANSITION, EASING
	)
	$ShakeTween.start()


func _on_Frequency_timeout():
	_new_shake()


func _on_Duration_timeout():
	_reset()
	$Frequency.stop()
