extends Node
class_name SpriteColorFlashRequestor
"""
A decoupled sprite color flash client that can be used to 
request a color flash happen with given parameters
"""
signal color_flash_requested(color, duration, blend, buildup_slice)

export(AudioStream) var flash_sound
export(Color) var color := Color.blue
export(float) var total_duration := 0.3
export(float) var max_blend := 0.8
export(float) var buildup_slice := 0.7


onready var audio_player: AudioStreamPlayer = _create_audio_player()

func _ready():
	add_to_group("color_flashers", true)
	set_process(false)
	set_physics_process(false)
	audio_player.stream = flash_sound
	audio_player.autoplay = false
	audio_player.pitch_scale = 2.5
	
	
func request_color_flash(color = Color.blue, total_duration = 0.3, max_blend = 0.8, buildup_slice = 0.7):
	audio_player.play(0)
	emit_signal("color_flash_requested", color, total_duration, max_blend, buildup_slice)
	


func build_color_flash(params: Dictionary = {}):
	request_color_flash(
		Utils.get_or_default(params, 'color', color),
		Utils.get_or_default(params, 'total_duration', total_duration),
		Utils.get_or_default(params, 'max_blend', max_blend),
		Utils.get_or_default(params, 'buildup_slice', buildup_slice)
	)


func _create_audio_player() -> AudioStreamPlayer:
	var player = AudioStreamPlayer.new()
	add_child(player)
	return player
