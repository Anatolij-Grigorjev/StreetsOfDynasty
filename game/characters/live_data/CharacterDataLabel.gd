extends Label
class_name CharacterDataLabel
"""
Base class for labels that display different character properties
"""

func display_info(character_node: CharacterTemplate):
	text = "<BASE>%s|%s" % [self, character_node]
