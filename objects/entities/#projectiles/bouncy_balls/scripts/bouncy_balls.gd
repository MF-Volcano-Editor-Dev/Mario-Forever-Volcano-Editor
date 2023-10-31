extends EntityBody2D

## Emitted when the projectile is to be destroyed
signal projectile_destroy

@export_category("Bouncy Ball")
## Jumping speed
@export_range(0, 1, 0.001, "or_greater", "hide_slider", "suffix:px/s") var jumping_speed: float = 250
## Bouncing times
@export_range(0, 50, 1, "suffix:times") var bouncing_wall_times: int


func _physics_process(_delta: float) -> void:
	move_and_slide()


func bounce_floor() -> void:
	jump(jumping_speed)


func bounce_wall() -> void:
	turn_x()
	
	bouncing_wall_times -= 1
	if bouncing_wall_times <= 0:
		destroy()


func destroy() -> void:
	projectile_destroy.emit()
	queue_free()
