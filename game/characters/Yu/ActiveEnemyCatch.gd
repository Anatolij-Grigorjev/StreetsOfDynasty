extends RayCast2D
"""
A raycast on Yu to walk into enemies and catch them
"""


"""
Radius of catching by walking into enemies - 
any collision outside of half of this in 
terms of Z axis will be ignored
"""
export(float) var catch_radius = 40.0



func _ready():
	pass
	

func get_caught_enemy():
	var caught = get_collider()
	if (not caught):
		return null
	var character = Utils.get_areagroup_area_owner(caught)
	if (not character):
		return null
	if (character.invincibility):
		return null
	if(not Utils.positions_in_z_range(
		character.global_position, 
		owner.global_position, 
		catch_radius
	)):
		return null
	return character
