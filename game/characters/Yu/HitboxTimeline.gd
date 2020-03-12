extends AreaGroupTimeline

onready var LOG: Logger = $Logger


func _ready():
	call_deferred("log_areas")


func log_areas():
	LOG.info("got {} areas in group: {}", [area_group.all_areas.size(), area_group.all_areas])


func _apply_timeline_item(timeline_item: Dictionary):
	._apply_timeline_item(timeline_item)
	LOG.info("applied item: {}", [timeline_item])
