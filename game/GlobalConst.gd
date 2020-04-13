class_name C
"""
Global utility holder for game-wide constants
"""
enum DamageType {
	BLUNT = 0,
	BLEEDING = 1
}

enum AttackPhase {
	WIND_UP = 0,
	HIT = 1,
	WIND_DOWN = 2
}

enum AttackInputType {
	NONE = 0,
	NORMAL = 1,
	SPECIAL = 2
}

enum CharacterMoveType {
	MOVE_SLIDE = 0,
	MOVE_COLLIDE = 1
}
