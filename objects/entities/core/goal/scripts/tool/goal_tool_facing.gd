@tool
extends Node

var _direction: int

func _process(_delta: float) -> void:
	var goal := get_parent() as Goal
	if !goal:
		return
	if _direction == goal.direction:
		return
	_direction = goal.direction
	goal.scale.x = -goal.direction
	
	if Engine.is_editor_hint():
		return
	queue_free() # Destroy when not in editor mode
