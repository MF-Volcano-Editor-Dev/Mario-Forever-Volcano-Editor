class_name one extends EntityBody2D

var speed: float = 500
var has_sped: bool


func _physics_process(delta: float) -> void:
	if !has_sped:
		accelerate_local_x(speed, 500)
		if velocity.x >= speed - 100:
			has_sped = true
	
	calculate_gravity()
	move_and_slide()
