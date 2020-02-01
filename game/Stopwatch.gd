extends Timer
class_name Stopwatch
"""
A kind of timer that also allows to query the elapsed time
since timer started
"""


var time_elapsed: float = 0.0 setget , _get_elapsed_time


func _get_elapsed_time() -> float:
	if (is_stopped()):
		return 0.0
	else:
		return wait_time - time_left
