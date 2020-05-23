extends Node
class_name ScreenShakeRequestor
"""
can be used to request a camera-based screen shake with provided
parameters

Usage requires the ScreenShake.tscn scene attached as 
direct child of an active Camera2D node
"""
signal camera_shake_requested(duration, frequency, amplitude, priority)

export(float) var default_duration = 0.2
export(int) var default_frequency = 15
export(int) var default_amplitude = 10
export(int) var default_priority = 1


func _ready():
	add_to_group("camera_shakers", true)
	set_process(false)
	set_physics_process(false)
	
	
func request_screen_shake(duration = 0.2, frequency = 15, amplitude = 10, priority = 1):
	emit_signal("camera_shake_requested", duration, frequency, amplitude, priority)
	
	
func build_screen_shake(values: Dictionary):
	request_screen_shake(
		Utils.get_or_default(values, 'duration', default_duration),
		Utils.get_or_default(values, 'frequency', default_frequency),
		Utils.get_or_default(values, 'amplitude', default_amplitude),
		Utils.get_or_default(values, 'priority', default_priority)
	)
