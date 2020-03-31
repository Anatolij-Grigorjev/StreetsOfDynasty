extends Node2D
"""
An action that can be attached to a given Camera2D to perform 
screen shake on-demand
"""
const TRANSITION = Tween.TRANS_SINE
const EASING = Tween.EASE_OUT_IN

var amplitude = 0
var priority = 0

onready var camera: Camera2D = get_parent()


func _ready():
	#deferred to wait for all script-based group adds
	call_deferred("_connect_shakers")


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
	priority = 0


func _on_Frequency_timeout():
	_new_shake()


func _on_Duration_timeout():
	_reset()
	$Frequency.stop()


func _on_camera_shake_requested(duration = 0.2, frequency = 15, amplitude = 10, priority = 1):
	if (priority < self.priority):
		return
	
	self.amplitude = amplitude
	self.priority = priority
	$Duration.wait_time = duration
	$Frequency.wait_time = 1 / float(frequency)
	$Duration.start()
	$Frequency.start()
	
	_new_shake()


func _connect_shakers():
	for shaker in get_tree().get_nodes_in_group("camera_shakers"):
		shaker.connect("camera_shake_requested", self, "_on_camera_shake_requested")
