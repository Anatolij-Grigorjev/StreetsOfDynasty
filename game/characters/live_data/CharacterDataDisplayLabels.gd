extends Node2D
class_name CharacterDataDisplayLabels
"""
Container that uses a character template (parent by default) as source
of information to dipslay and alter in real time
"""

export(NodePath) var character_node_path = ".."

onready var character_node: CharacterTemplate = get_node(character_node_path)

var labels_list: Array = []

func _ready():
	labels_list = _collect_labels_list()
	
	
func _process(delta):
	for label in labels_list:
		label.display_info(character_node)
	
	
func _collect_labels_list() -> Array:
	var labels = []
	for node in get_children():
		if (node as CharacterDataLabel):
			labels.append(node)
	return labels
