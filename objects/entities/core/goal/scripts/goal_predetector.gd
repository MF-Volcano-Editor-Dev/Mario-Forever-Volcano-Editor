extends AnimatedSprite2D

@onready var goal := get_parent() as Goal


func _ready() -> void:
	if !goal:
		return
	
	goal.detection_area = goal.detection_area.expand(Vector2(sign(position.x), 0) * absf(position.x))
