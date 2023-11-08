extends CharacterBody2D


func _physics_process(delta: float) -> void:
	move_and_slide()
	print(get_last_slide_collision())
