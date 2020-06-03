extends Label

export(String) var fps_format = "%2.2f"
export(String) var timescale_format = "%1.3f"
	
func _process(delta):
	text = """
		FPS: %s
		Timescale: %s 
	""" % [
			fps_format % Engine.get_frames_per_second(), 
			timescale_format % Engine.time_scale
	]
