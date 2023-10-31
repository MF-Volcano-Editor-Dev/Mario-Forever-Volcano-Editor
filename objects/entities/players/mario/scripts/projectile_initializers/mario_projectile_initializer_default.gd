extends Component

@export_category("Mario Projectile Initializer")
@export_group("Velocity", "velocity_")
@export var velocity_property_name = &"velocity"
@export var velocity_value: Vector2
@export var velocity_direction_tracking: bool = true
@export_group("Gravity", "gravity_")
@export var gravity_property_name = &"gravity"
@export_range(-1, 1, 0.001, "or_less", "or_greater", "hide_slider", "suffix:px/s²") var gravity_value: float


func initialize_projectile(player: Mario2D, projectile: Node2D) -> void:
	var vel: Vector2 = Vector2(velocity_value.x * (player.direction if velocity_direction_tracking else 1), velocity_value.y)
	
	projectile.set(velocity_property_name, vel)
	projectile.set(gravity_property_name, gravity_value)
