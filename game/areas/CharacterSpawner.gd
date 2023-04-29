extends Position2D
class_name CharacterSpawn
"""
Spawn characters of provided prefab within specified subtree of scene
by default - under parent of this spawner
"""

export(PackedScene) var character_scn: PackedScene
export(NodePath) var spawn_parent_path: NodePath = NodePath('..')

onready var spawn_parent_node: Node = get_node(spawn_parent_path)

func spawn() -> CharacterTemplate:
	var character = character_scn.instance()
	spawn_parent_node.add_child(character)
	character.global_position = global_position
	return character as CharacterTemplate
