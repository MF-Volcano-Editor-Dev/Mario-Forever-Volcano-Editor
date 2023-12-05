extends AnimatedSprite2D

@onready var goal := get_parent() as Goal


func _ready() -> void:
	if !goal:
		return
	goal.detection_area = goal.detection_area.expand(Vector2(signf(position.x * -goal.direction), 0) * absf(position.x)) # Expands the detection area left
