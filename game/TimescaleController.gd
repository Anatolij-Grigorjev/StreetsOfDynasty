extends Node
"""
Controls slowdowns and speedups of engine time based on 
incoming signals
"""
const LOWEST_PRIORITY = -999


var current_priority: int = LOWEST_PRIORITY


func _ready():
	#connect all interested in slowdown
	call_deferred("_connect_timescalers")


func _start_timescale(scale = 0.9, duration = 0.15, priority = 1):
	if (priority < self.current_priority):
		return
	
	self.current_priority = priority
	Engine.time_scale = scale
	$Duration.wait_time = duration
	$Duration.start()
	
	
func _on_Duration_timeout():
	_reset_timescale()
	self.current_priority = LOWEST_PRIORITY
	
	
func _reset_timescale():
	Engine.time_scale = 1.0


func _connect_timescalers():
	for scaler in get_tree().get_nodes_in_group("timescalers"):
		scaler.connect("timescale_requested", self, "_start_timescale")
