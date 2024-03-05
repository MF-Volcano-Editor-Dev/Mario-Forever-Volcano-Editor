extends Area2D

func _ready() -> void:
	body_entered.connect(func(body: Node2D):
		if body is Mario:
			body.starman()
	)
