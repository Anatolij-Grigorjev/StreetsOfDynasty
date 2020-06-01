extends Node2D
"""
This class will provde global drawable debug facilities
for any in the project
"""

"""
Global logging facility for classes
"""
var LoggerFactory = preload("res://Logger.tscn")
var LOG: Logger


"""
Draw shape constants allowed for basic debug shapes onscreen
"""
const DRAW_TYPE_LINE = 'line'
const DRAW_TYPE_CIRCLE = 'circle'



var draw_q: Array = []

func _ready():
	LOG = LoggerFactory.instance()
	LOG.skip_stackframes = 4
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
			
			
func get_debug1_pressed() -> bool:
	return Input.is_action_just_pressed("debug1")
	
	
func log_debug(message: String, params: Array = []):
	_log_with_available(Logger.LogLevel.DEBUG, message, params)
	

func log_info(message: String, params: Array = []):
	_log_with_available(Logger.LogLevel.INFO, message, params)
	

func log_warn(message: String, params: Array = []):
	_log_with_available(Logger.LogLevel.WARN, message, params)
	
	
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


func _log_with_available(log_level: int, message: String, params: Array):
	if (is_instance_valid(LOG)):
		_log_by_logger(log_level, message, params)
	else:
		_log_by_print("<INIT>", message, params)


func _log_by_logger(log_level: int, message: String, params: Array):
	LOG._log_at_level(log_level, message, params)
	
	
func _log_by_print(log_level: String, message: String, params: Array):
	print("%s: %s" % [log_level, Utils.format_message(message, params)])
