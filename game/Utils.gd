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
	
	
"""
Get the value at specified key from dictionary. 
If key not present return default
"""
static func get_or_default(dict: Dictionary, key: String, default):
	if (dict != null and dict.has(key)):
		return dict[key]
	else: 
		return default
	
	
"""
Convert Object properties x and y into a vector2 object
"""
static func dict2vector(dict: Dictionary) -> Vector2:
	if (dict):
		return Vector2(dict.x, dict.y)
	else:
		return Vector2.ZERO
		
		
"""
Merge keys from 2 dictionaries into a new one (does not alter param dicts). 
Conflicts resolved in favor of second dictionary
"""
static func merge_dicts(dict1: Dictionary, dict2: Dictionary):
	if (dict1 == null or dict1.empty()):
		return dict2
	if (dict2 == null or dict2.empty()):
		return dict1
		
	var merged_dict = {}
	for key in dict1:
		merged_dict[key] = dict1[key]
	for key in dict2:
		merged_dict[key]	= dict2[key]
	
	return merged_dict	
