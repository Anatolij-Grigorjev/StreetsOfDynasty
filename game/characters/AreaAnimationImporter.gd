extends Node
class_name AreaAnimationImporter
"""
This utility imports area animation information in JSON format from specified path
And then parses it into animation tracks involving specified animator
and specified AreaGroup
"""
export(String) var animation_data_path: String
export(NodePath) var animator_path: NodePath
export(NodePath) var area_group_path: NodePath


onready var animator: AnimationPlayer = get_node(animator_path)
onready var area_group_name: String = get_node(area_group_path).name


func _ready():
	if (not _are_parameters_valid()):
		return

	#this is parsed json data
	var area_timing_json: Array = _get_valid_file_json(animation_data_path)
	if (not area_timing_json):
		return
	
	for timing_track in area_timing_json:
		_build_timing_track(timing_track)
	

func _build_timing_track(timing_track_json: Dictionary) -> void:
	var animation: Animation = \
		animator.get_animation(timing_track_json.animation)
	if (not is_instance_valid(animation)):
		return
	var key_time: float = _get_key_time(timing_track_json.timing)
	if (key_time < 0.0):
		key_time = animation.length
	var animation_key: Dictionary = \
		_build_switch_area_key(timing_track_json.enable_area)
	var track_idx = animation.add_track(Animation.TYPE_METHOD)
	animation.track_set_path(track_idx, area_group_name)
	animation.track_insert_key(track_idx, key_time, animation_key)
	
	
	
func _build_switch_area_key(switch_area: String) -> Dictionary:
	return {
		'name': "switch_to_area",
		'arg_count': 1,
		'args': [
			{
				'type': 'String',
				'value': switch_area
			}
		]
	}
	
	
	
func _get_key_time(json_timing: String) -> float:
	if (not json_timing or json_timing == "start"):
		return 0.0
	elif (json_timing == "end"):
		return -1.0
	else:
		return json_timing.to_float()
	
	

func _are_parameters_valid() -> bool:
	return (
		is_instance_valid(animator) 
		and area_group_name
		and animation_data_path
	)
	
	
func _get_valid_file(path: String) -> File:
	var file := File.new()
	var error := file.open(path, File.READ)
	if (error != OK):
		print("Error opening AreaGroup JSON animation file %s" % path)
		return null
	else:
		return file
		
	
func _get_valid_json(text: String):
	var json_errors := validate_json(text)
	if (json_errors):
		print("Error parsing AreaGroup animation JSON %s, got error: '%s'" % [text, json_errors])
		return null
		
	return parse_json(text)
	
	
func _get_valid_file_json(filepath: String):
	var file: File = _get_valid_file(filepath)
	if (not file):
		return null
	var valid_json = _get_valid_json(file.get_as_text())
	if (not valid_json):
		return null
	
	return valid_json
