extends Node

@export_category("Projectile Initializer")
@export_group("Velocity")
@export var velocity: Dictionary = {
	property_name = &"velocity",
	value = Vector2.ZERO
}
@export var gravity: Dictionary = {
	property_name = &"gravity",
	value = null
}
@export var velocity_direction_tracking: bool = true


func initialize_projectile(player: Mario2D, projectile: Node2D) -> void:
	var vel: Vector2 = Vector2(velocity.value.x * (1 if velocity_direction_tracking else player.direction), velocity.value.y)
	
	projectile.set(velocity.property_name, vel)
	projectile.set(gravity.property_name, gravity.value)
