extends State
class_name DyingStateAspect
"""
State aspect to show last animations of character 
before leaving behind corpse
"""
export(PackedScene) var CorpseScene
export(Vector2) var corpse_offset = Vector2.ZERO

onready var state: FiniteState = get_parent()
	
	
func exit_state(next_state: String):
	.exit_state(next_state)
	_leave_corpse()
	entity.queue_free()
	
	
func _leave_corpse():
	#build
	var corpse := _build_facing_position_aware_corpse()
	
	#add corpse to corpses in scene
	var corpses_node = Utils.get_node_by_tag("corpses")
	corpses_node.add_child(corpse)
	
	Debug.LOG.info("%s leaving corpse at %s", [entity, corpse.global_position])
	
	
func _build_facing_position_aware_corpse() -> Node2D:
	var corpse = CorpseScene.instance()
	corpse.get_node("Sprite").scale.x *= sign(entity.facing)
	corpse.global_position = entity.global_position + corpse_offset
	corpse.get_node("Label").text = "%3.3f;%3.3f" % [corpse.global_position.x, corpse.global_position.y]
	return corpse
