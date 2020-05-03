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
	self.z_index = 999
	
	
func add_global_draw(draw_item: Dictionary):
	assert(draw_item.has('type'), 'Drawing must have a type!')
	draw_q.append(draw_item)
	
	
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