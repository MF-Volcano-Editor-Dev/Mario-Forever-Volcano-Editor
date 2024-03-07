extends Node2D

@onready var par: Node2D = get_parent()


func _process(_delta: float) -> void:
	var facing = par.get_meta(&"facing", 1)
	if facing in [-1.0, 1.0]:
		transform.x.x = absf(transform.x.x) * facing
	else:
		par.get_meta(&"facing", 1)
