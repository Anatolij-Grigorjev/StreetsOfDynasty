extends Node

class_name RecentItemsDictionary
"""
An items list that only holds onto those it consides 'recent',
as defined by the initial TTL
the user is expected to include #process calls into the timeline
of the running scene, since this class is not a part of it

"""
var _values: Dictionary = {}


export (float) var items_ttl_seconds: float = 1.0
	
	
func has_item(item) -> bool:
	return _values.has(item)


func add_item(item):
	_values[item] = items_ttl_seconds
	

func _remove_item(item):
	_values.erase(item)
	

func _process(delta: float):
	var expired_items = []
	for item in _values:
		_values[item] -= delta
		if (_values[item] <= 0.0):
			expired_items.append(item)
			
	if (expired_items):
		for expired_item in expired_items:
			_remove_item(expired_item)
