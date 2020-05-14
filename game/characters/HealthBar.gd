extends Control
"""
Management of health bar as the amount of health in it is adjusted
"""
export(float) var tween_bar_delay := 0.25
export(float) var tween_bar_move := 0.5

onready var reduce_tween_bar: ProgressBar = $BarReduceBG
onready var main_bar: ProgressBar = $MainBar
onready var tween: Tween = $Tween



func _ready():
	pass
	
	
func set_total(new_total: float):
	main_bar.max_value = new_total
	main_bar.value = new_total
	
	reduce_tween_bar.max_value = new_total
	reduce_tween_bar.value = new_total
	
	
func set_new_value(new_value: float):
	
	tween.interpolate_property(
		reduce_tween_bar, 'value', 
		null, new_value, 
		tween_bar_move, 
		Tween.TRANS_LINEAR, Tween.EASE_IN, tween_bar_delay
	)
	tween.start()
	main_bar.value = new_value
	
	
func _on_character_damage_received(damage: float, health: float, total_healt: float):
	set_new_value(health)

