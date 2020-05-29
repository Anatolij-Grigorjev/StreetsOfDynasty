extends CharacterDataLabel
class_name CharacterStabilityLabel


export(String) var format = "ST: %d/%d"


func display_info(character_node: CharacterTemplate):
	text = format % [character_node.stability, character_node.total_stability]
