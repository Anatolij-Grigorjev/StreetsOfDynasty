class_name Utils
"""
Static utility methods
"""

"""
Generate random Vector2 with coordinates between
(-range_x;-range_y) and (range_x;range_y)
"""
static func rand_point(range_x: float, range_y: float) -> Vector2:
	return Vector2(
		rand_range(-range_x, range_x),
		rand_range(-range_y, range_y)
	)
	
	
"""
Import JSON file at specified path. Throws if JSON could not be parsed
"""
static func get_json_from_file(filepath: String): 
	var json_text := get_file_text(filepath)
	return parse_json(json_text)
	

"""
Read contents of file into String as text
"""
static func get_file_text(filepath: String) -> String:
	var file: File = File.new()
	file.open(filepath, File.READ)
	var file_text: String = file.get_as_text()
	file.close()
	return file_text
