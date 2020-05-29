extends CharacterDataLabel
class_name CharacterPositionLabel


export(String) var position_format = "%3.3f;%3.3f"


func display_info(character_node: CharacterTemplate):
	var character_position = character_node.global_position
	text = position_format % [character_position.x, character_position.y]
