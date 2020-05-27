extends Node
"""
Control blinking cahracter with induced invincibility
Node disabled collision areas and blinks sprites
Accepts lists of exceptions
"""
export(float) var duration = 2.0
export(int) var blink_frequency = 2
export(Array, String) var pre_blink_states = [
	"Falling"
]
export(Array, NodePath) var dont_blink_sprites = []  


onready var duration_timer: Timer = $Duration
onready var blink_timer: Timer = $BlinkTime
onready var entity = get_parent()

var blink_sprites := []

var sprites_visible := true setget set_sprites_visible

func _ready():
	blink_sprites = _collect_entity_sprites(entity)
	for exclude_sprite in dont_blink_sprites:
		blink_sprites.erase(exclude_sprite)
	
	Debug.LOG.info("{} Blinker collected {}(-{}) sprites!", [
		entity,
		blink_sprites.size(), dont_blink_sprites.size()
	])


func _on_CharacterTemplate_state_changed(prev_state: String, next_state: String):
	#character was fallen and is getting up
	if (prev_state in pre_blink_states 
		and not (next_state in pre_blink_states)):
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


func _collect_entity_sprites(root: Node) -> Array:
	var sprites := []
	_append_if_sprite(sprites, root)
	for child in root.get_children():
		_append_if_sprite(sprites, child)
		var child_sprites := _collect_entity_sprites(child)
		for sprite in child_sprites:
			sprites.append(sprite)
	
	return sprites
	
	
func _append_if_sprite(array, node):
	if (node is Sprite):
		array.append(node)


func _on_Duration_timeout():
	_stop_blinking()


func _on_BlinkTime_timeout():
	self.sprites_visible = not self.sprites_visible
	
	
func set_sprites_visible(value: bool):
	sprites_visible = value
	_toggle_sprites_visible(sprites_visible)
