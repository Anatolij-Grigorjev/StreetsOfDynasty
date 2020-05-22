extends HitEffectTemplate
"""
A type of hi effect that plays a sound when invoked
"""

export(AudioStream) var HitSoundFx

onready var sound_player: AudioStreamPlayer2D = $SoundFX


func _ready():
	sound_player.stream = HitSoundFx


func invoke_hit_fx(hit_connect: HitConnect):
	if (sound_player.is_playing()):
		return
	var db_scale = 0.25
	var pitch_scale = 0.25
	sound_player.volume_db = rand_range(-db_scale, db_scale)
	sound_player.pitch_scale = rand_range(1 - pitch_scale, 1 + pitch_scale)
	
	sound_player.play()
