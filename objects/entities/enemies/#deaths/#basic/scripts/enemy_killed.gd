extends EntityBody2D

@export_category("Enemy Killed")
@export var initial_speed_range: Vector2 = Vector2(100, 300)
@export_range(0, 60, 0.001, "degrees") var initial_velocity_direction: float = 45


func _ready() -> void:
	var angle := deg_to_rad(randf_range(-initial_velocity_direction, initial_velocity_direction))
	velocity = Vector2.UP.rotated(angle) * randf_range(initial_speed_range.x, initial_speed_range.y)

func _physics_process(_delta: float) -> void:
	move_and_slide()
