extends Label

@export_category("Counter Label")
@export var counter_amount: int

@onready var posy: float = position.y


func _ready() -> void:
	text = str(counter_amount)
	if text.to_int() < 0:
		modulate = Color(1, 0.25, 0, modulate.a)
	
	var tw: Tween = create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tw.tween_property(self, ^"position:y", posy - 128, 0.75)
	tw.tween_interval(0.5)
	tw.tween_property(self, ^"modulate:a", 0, 0.25)
	await tw.finished
	queue_free()
