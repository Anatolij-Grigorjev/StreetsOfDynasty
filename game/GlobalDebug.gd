extends Node2D
"""
This class will provde global drawable debug facilities
for any in the project
"""
var LoggerFactory = preload("res://Logger.tscn")

"""
Global logging facility for classes
"""
const DRAW_TYPE_LINE = 'line'
const DRAW_TYPE_CIRCLE = 'circle'


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
	#clear drawings that expired by duration
	for drawing in draw_q:
		if (drawing.has('duration')):
			drawing.duration -= delta
		if (Utils.get_or_default(drawing, 'duration', 0.0) <= 0.0):
			draw_q.erase(drawing)
	
	
func _draw():
	for drawing in draw_q:
		LOG.info("Drawing item {}", [drawing])
		
		var color = Utils.get_or_default(drawing, 'color', Color.red)
		match(drawing.type):
			DRAW_TYPE_LINE:
				draw_line(drawing.from, drawing.to, color, 15.0)
				break
			DRAW_TYPE_CIRCLE:
				draw_circle(drawing.center, drawing.radius, color)
				break
			_:
				LOG.warn("Unsupported drawing type {}", drawing.type)
				breakpoint
