extends Node
class_name Logger
"""
General purpouse logger to be used for pretty-printing messages with
meaning in a given script.

Attaches as a child to the node in which it needs to log and 
uses the info of that node as its main descriptor
Logger is preconfigured with pattern 
<date time> <LOG LEVEL> <descriptor>#<method>:<line number> - <msg>

Usage: 

func test() -> void:
	var LOG: Logger = @Logger
	LOG.info('hello!') 
^^^^ assuming invocation time and doing in script of node named 'Node' and same line numbers:
2019.09.08 14:34:20 INFO Node#test:16 - hello!


class can also invoke breakpoints when the #error log method is called
to fail-fast handle error situations
"""
const DATETIME_FORMAT := "%04d.%02d.%02d %02d:%02d:%02d"
const LOG_LEVEL_NAMES : Array = [ "DEBUG", "INFO", "WARN", "ERROR" ]


enum LogLevel {
	DEBUG = 0,
	INFO = 1, 
	WARN = 2,
	ERROR = 3
}

"""
Is this logger completely disabled
"""
export(bool) var enabled: bool = true
"""
For an enabled logger, which log levels are actually logged
"""
export(Array, LogLevel) var enabled_levels: Array = [
		LogLevel.INFO, 
		LogLevel.WARN, 
		LogLevel.ERROR
	]

"""
Log descriptor
"""
var _logger_name: String


"""
Create a bound logger instance with the given descriptor.
"""
func _ready():
	_logger_name = (
		get_parent() if is_instance_valid(get_parent()) 
			else self
		).name
	info("Created logger '{}'!", [_logger_name])
	

"""
Log message at DEBUG level. 
Should be used for dumping variable state and other auxillary info for 
problem analysis purpouses that is notimportant for regular game runs.
"""
func debug(message: String, params: Array = []) -> void:
	_log_at_level(LogLevel.DEBUG, message, params)


"""
Log message at INFO level. 
Should be the preferred level for printing good-to-know information that
does not indicate a problem situation.
"""
func info(message: String, params: Array = []) -> void:
	_log_at_level(LogLevel.INFO, message, params)
	
	
"""
Log message as WARN level.
Should be used for messages pertaining to receoverable problem 
situations encountered during system run.
"""
func warn(message: String, params: Array = []) -> void:
	_log_at_level(LogLevel.WARN, message, params)
	
	
"""
Log message as ERROR level. 
Should be used for messages pertaining to non-recoverable problems and
system faults that require immediate attention. 
By default will break execution flow in debugger.
"""	
func error(message: String, params: Array = [], break_here: bool = true) -> void:
	_log_at_level(LogLevel.ERROR, message, params)
	if (break_here):
		breakpoint


func _log_at_level(level: int, message: String, params: Array) -> void:
	if (not _can_log_at_level(level)):
		return
	#the get_datetime parameter asks if timezone is UTC
	#this logger logs in local time
	var current_datetime := OS.get_datetime(false)
	var log_level_name : String = LOG_LEVEL_NAMES[level]
	var call_stack : Array = get_stack()
	# frame 0 is this private method, 
	# frame 1 would be the log level wrapper
	# frame 2 is then the method that invoked the logging
	# might have fewer frames if logger tested standalone
	var stack_frame_idx := min(2, call_stack.size() - 1)
	var current_stack_frame : Dictionary = call_stack[stack_frame_idx]
	var resolved_message: String = _resolve_message_params(message, params)
	
	var full_message : String = ("%s %s %s.%s:%s - %s"
	% [
		_format_datetime_dict(current_datetime), 
		log_level_name, 
		_logger_name, 
		current_stack_frame.function,
		current_stack_frame.line,
		resolved_message
	])

	print(full_message)
	

func _format_datetime_dict(datetime_dict: Dictionary) -> String:
	return DATETIME_FORMAT % [
		datetime_dict.year,
		datetime_dict.month,
		datetime_dict.day,
		datetime_dict.hour,
		datetime_dict.minute,
		datetime_dict.second
	]	


func _resolve_message_params(message: String, params: Array) -> String:
	if (not message):
		return ""
	if (not params):
		return message
	
	#handle logback-style messages
	var internal_template = message.replace("{}", "%s")
	
	return internal_template % params
	

func _can_log_at_level(level: int) -> bool:
	return enabled and enabled_levels.has(level)
