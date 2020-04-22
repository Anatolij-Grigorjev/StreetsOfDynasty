extends State
class_name DyingStateAspect
"""
State aspect to show last animations of character 
before leaving behind corpse
"""
export(PackedScene) var CorpseScene

onready var state: FiniteState = get_parent()

func _ready():
	#ensure this state lasts as long as animation
	state.init_animation_length_state()
	
	
func exit_state(next_state: String):
	.exit_state(next_state)
	_leave_corpse()
	entity.queue_free()
	
	
func _leave_corpse():
	var corpse = CorpseScene.instance()
	corpse.global_position = entity.global_position
	#add corpse to corpses in scene
	var corpses_node = Utils.get_node_by_tag("corpses")
	corpses_node.add_child(corpse)
