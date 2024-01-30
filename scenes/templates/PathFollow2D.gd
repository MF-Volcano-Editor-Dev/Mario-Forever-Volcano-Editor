extends PathFollow2D


func _physics_process(delta: float) -> void:
	progress += 50 * delta
