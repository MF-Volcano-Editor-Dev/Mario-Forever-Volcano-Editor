extends EntityBody2D


func _ready() -> void:
	print(ExtensiveMath.Calculus.derivative_at(
			func(x: float) -> float: return x ** 2,
			0.5)
	)


func _physics_process(delta: float) -> void:
	move(delta)
