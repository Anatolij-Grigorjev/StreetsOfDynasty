class_name SingleReadVar
"""
A value holder that resets value after read
"""

var stable_value

var current_value setget ,read_and_reset

"""
Make new holder with specified initial value
"""
func _init(stable_value):
	self.stable_value = stable_value
	self.current_value = self.stable_value
	

"""
Check current value without mutating it by reading
"""
func peek():
	return current_value


"""
Read current value, mutating back to stable state
"""
func read_and_reset():
	var read_val = current_value
	self.current_value = stable_value
	return read_val
