extends Node2D

@export_category("Sprite")
@export var scale_x_to_parent_direction: bool = true
@export_range(-18000, 18000, 0.001, "suffix:°/s") var rotation_speed: float = 250

@onready var enemy_dead_body: Node2D = get_parent()


func _process(delta: float) -> void:
	if scale_x_to_parent_direction:
		scale.x = enemy_dead_body.direction
	
	rotate(deg_to_rad(rotation_speed) * delta * enemy_dead_body.direction)
