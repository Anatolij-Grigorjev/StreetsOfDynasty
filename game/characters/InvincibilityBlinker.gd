extends Node
"""
Control blinking cahracter with induced invincibility
Node disabled collision areas and blinks sprites
Accepts lists of exceptions
"""
export(float) var duration = 2.0
export(int) var blink_frequency = 2
export(Array, String) var pre_blink_states = [
	"Falling",
	"Fallen",
	"Dying"
]
export(Array, NodePath) var dont_blink_sprites_paths = []  


onready var duration_timer: Timer = $Duration
onready var blink_timer: Timer = $BlinkTime
onready var entity = get_parent()

var blink_sprites := []

var sprites_visible := true setget set_sprites_visible

func _ready():
	var all_sprites_by_id = _collect_entity_sprites_map(entity)
	var dont_blink_sprites = _collect_exclusions()
	
	blink_sprites = _collect_blink_sprites(all_sprites_by_id, dont_blink_sprites)
	
	Debug.log_info("{} Blinker collected {}(={}-{}) sprite(-s)!", [
		entity,
		blink_sprites.size(), 
		all_sprites_by_id.size(), dont_blink_sprites.size()
	])


func _on_CharacterTemplate_state_changed(prev_state: String, next_state: String):
	#character was fallen and is getting up
	if (prev_state in pre_blink_states 
		and not (next_state in pre_blink_states)):
		Debug.log_info("[!!!BLINK!!!]: '{}' -> '{}'", [prev_state, next_state])
		start()



func start(duration = self.duration, frequency = self.blink_frequency):
	self.duration = duration
	duration_timer.wait_time = duration
	self.blink_frequency = frequency
	#one full blink is invisible + visible, so multiply frequency
	blink_timer.wait_time = 1.0 / (frequency * 2.0)
	
	_start_blinking()



func _start_blinking():
	self.sprites_visible = false
	duration_timer.start()
	blink_timer.start()
	entity.invincibility = true
	
	
func _stop_blinking():
	self.sprites_visible = true
	duration_timer.stop()
	blink_timer.stop()
	entity.invincibility = false
		

func _toggle_sprites_visible(visible: bool):
	for node in blink_sprites:
		var sprite: Sprite = node
		sprite.visible = visible


func _collect_entity_sprites_map(root: Node) -> Dictionary:
	var sprites := {}
	_append_if_missing_sprite(sprites, root)
	for child in root.get_children():
		_append_if_missing_sprite(sprites, child)
		var child_sprites := _collect_entity_sprites_map(child)
		for sprite_id in child_sprites.keys():
			_append_if_missing_sprite(sprites, child_sprites[sprite_id])
	return sprites
	
	
func _append_if_missing_sprite(id_to_sprite: Dictionary, node: Object):
	if (node is Sprite):
		id_to_sprite[node.get_instance_id()] = node


func _collect_exclusions() -> Array:
	var found_nodes := []
	for path in dont_blink_sprites_paths:
		var node = get_node(path)
		if (is_instance_valid(node)):
			found_nodes.push_back(node)
	return found_nodes


func _collect_blink_sprites(all_sprites_dict: Dictionary, exclude_sprites: Array) -> Array:

	var blink_allowed_dict: Dictionary = Utils.copy_dict(all_sprites_dict)
	
	for exclude_node in exclude_sprites:
		var exclude_id = exclude_node.get_instance_id()
		blink_allowed_dict.erase(exclude_id)
	
	return blink_allowed_dict.values()



func _on_Duration_timeout():
	_stop_blinking()


func _on_BlinkTime_timeout():
	self.sprites_visible = not self.sprites_visible
	
	
func set_sprites_visible(value: bool):
	sprites_visible = value
	_toggle_sprites_visible(sprites_visible)
