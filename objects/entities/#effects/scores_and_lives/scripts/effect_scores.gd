extends Label


func _ready() -> void:
	var tw := create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tw.tween_property(self, "position:y", position.y - 96, 1)
	tw.tween_interval(1)
	tw.tween_property(self, "modulate:a", 0, 0.25).set_trans(Tween.TRANS_LINEAR)
	tw.play()
	
	await tw.finished
	queue_free()


func set_display(amount: int) -> void:
	text = str(amount)
