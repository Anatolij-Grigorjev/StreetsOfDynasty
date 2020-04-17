extends Node2D
"""
This class will provde global drawable debug facilities
for any in the project
"""
var LoggerFactory = preload("res://Logger.tscn")

"""
Global logging facility for classes
"""
var LOG: Logger

var draw_q: Array = []

func _ready():
	LOG = LoggerFactory.instance()
	add_child(LOG)
	var stage = get_tree().get_root().get_node("WhiteBox")
	var stage_position = stage.global_position
	LOG.info("Moving from {} to {}...", [global_position, stage_position])
	self.global_position = stage_position
	self.z_index = 999
	
	
func _process(delta):
	update()
	
	
func _draw():
	for drawing in draw_q:
		LOG.info("Drawing item {}", [drawing])
		var color = drawing.color if drawing.has('color') else Color.red
		match(drawing.type):
			'line':
				draw_line(drawing.from, drawing.to, color, 15.0)
				break
			'circle':
				draw_circle(drawing.center, drawing.radius, color)
				break
			_:
				LOG.warn("Unsupported drawing type {}", drawing.type)
				breakpoint
	draw_q.clear()
