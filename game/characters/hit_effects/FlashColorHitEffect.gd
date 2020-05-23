extends HitEffectTemplate
"""
A type of hit effect that emits signal for entity to flash
specific color during hit (via sprite shader) for a specific duration
"""
signal color_flash_hit_received(color, duration)

export(Color) var flash_color: Color = Color.black
export(float) var duration: float = 0.2


func invoke_hit_fx(hit_connect: HitConnect):
	emit_signal("color_flash_hit_received", flash_color, duration)
