extends EntityBody2D

## Emitted when the projectile is to be destroyed
signal ball_destroy

@export_category("Bouncy Ball")
## Jumping speed
@export_range(0, 1, 0.001, "or_greater", "hide_slider", "suffix:px/s") var jumping_speed: float = 250
## Bouncing times
@export_range(0, 50, 1, "suffix:times") var bouncing_times: int = 12:
	set(value):
		bouncing_times = clampi(value, 0, 50)
		if bouncing_times <= 0:
			destroy()


func _physics_process(_delta: float) -> void:
	move_and_slide()


func bounce_floor() -> void:
	jump(jumping_speed)
	bouncing_times -= 1


func bounce_wall() -> void:
	turn_x()
	bouncing_times -= 1


func destroy() -> void:
	ball_destroy.emit()
