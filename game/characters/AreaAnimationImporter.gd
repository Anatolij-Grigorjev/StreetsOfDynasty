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
onready var area_group = get_node(area_group_path)


func _ready():
	if (not _are_parameters_valid()):
		return
	var file: File = _get_valid_file(animation_data_path)
	if (not file):
		return
	var area_timing_json = _get_valid_json(file.get_as_text())
	if (not area_timing_json):
		return
	#TODO: constrcut animator tracks



func _are_parameters_valid() -> bool:
	return (
		is_instance_valid(animator) 
		and is_instance_valid(area_group)
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
		print("Error parsing AreaGroup animation JSON %s, got error: '%s'" % [file_text, json_errors])
		return null
		
	return parse_json(text)
