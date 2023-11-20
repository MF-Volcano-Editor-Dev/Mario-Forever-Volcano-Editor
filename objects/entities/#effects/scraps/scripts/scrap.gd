extends EntityBody2D


func _process(delta: float) -> void:
	global_velocity += get_gravity_vector() * delta
	global_position += global_velocity * delta
