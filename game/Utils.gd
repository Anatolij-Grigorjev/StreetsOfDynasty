class_name Utils
"""
Static utility methods
"""


"""
Utility to square any number-like var
"""
static func sqr(num):
	return num * num

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
static func get_or_default(dict: Dictionary, key: String, default = null):
	if (dict != null and dict.has(key)):
		return dict[key]
	else: 
		return default
		

"""
Get value at nth array index with default fallback.
If the index is out of bounds or array is null, default is returned
"""
static func nth_or_default(array: Array, idx: int, default = null):
	if (array != null and array.size() > idx):
		return array[idx]
	else:
		return default

"""
Get back arg1 if its not null, or arg2 if it was
"""
static func nvl(value, default):
	return value if value != null else default

		
"""
Convert Object properties x and y into a vector2 object
"""
static func dict2vector(dict: Dictionary) -> Vector2:
	if (dict):
		return Vector2(dict.x, dict.y)
	else:
		return Vector2.ZERO
	
		
"""
Create a shallow copy of source_dict to preserve original before
manipulations of the keyset
"""
static func copy_dict(source_dict: Dictionary) -> Dictionary:
	var result_dict := {}
	for key in source_dict:
		result_dict[key] = source_dict[key]
	return result_dict


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


"""
Convert a collision polygon 2D with a rectangular shape 
into a Rect in global coordinates
"""
static func shape2rect(collider: CollisionShape2D) -> Rect2:
	return Rect2(
		collider.global_position - collider.shape.extents,
		collider.shape.extents * 2
	)


"""
Get the current rectangular overlap of 2 collision polygons that 
have rectangle shapes
"""
static func get_collision_rects_overlap(
	collider_a: CollisionShape2D, 
	collider_b: CollisionShape2D
) -> Rect2:
	var rect_a := shape2rect(collider_a)
	var rect_b := shape2rect(collider_b)
	
	return rect_a.clip(rect_b)
	
	
"""
Globally search for the first node within the specific group
(i.e. node with a specific tag)
"""
static func get_node_by_tag(tag: String) -> Node:
	var nodes = Debug.get_tree().get_nodes_in_group(tag)
	if (nodes):
		return nodes[0]
	else:
		return null
		

"""
Use the global Debug singleton node to access tree and add 'new_node'
at scene root
"""
static func add_at_scene_root(new_node: Node):
	Debug.get_tree().get_root().add_child(new_node)
	
	
"""
Format template params of  message, handle both regular and 
logback-style message params
"""
static func format_message(message: String, params: Array) -> String:
	if (not message):
		return ""
	if (not params):
		return message
	
	#handle logback-style messages
	var internal_template = message.replace("{}", "%s")
	
	return internal_template % params
	
	
"""
Join all array members into a single string using 
their string representation.
Empty string returned for empty inputs. never null
"""
static func join_to_string(elems: Array) -> String:
	if (elems == null or elems.empty()):
		return ""
	var cont_string: String = ""
	for elem in elems:
		cont_string += ("%s" % elem)
	
	return cont_string
	

"""
Attempt to resolve owner entity of this area which is assumed
a child of an AreaGroup node.
In case an entity is not resolved the function returns null
"""
static func get_areagroup_area_owner(area: Area2D) -> Node2D:
	var area_group = area.get_parent()
	if (not area_group.has_method('switch_to_area')):
		print("parent not areagroup!")
		return null
	return area_group.entity as Node2D
