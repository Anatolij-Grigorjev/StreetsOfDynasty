extends CharacterDataLabel
class_name CharacterStateLabel


func display_info(character_node: CharacterTemplate):
	var fsm = character_node.fsm
	text = fsm.state
