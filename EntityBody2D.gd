extends EntityBody2D


func _ready() -> void:
	print(ExtensiveMath.Ellipse.new(Vector2.ZERO, Vector2(2, 3)).get_length_fast())


func _physics_process(delta: float) -> void:
	move(delta)
