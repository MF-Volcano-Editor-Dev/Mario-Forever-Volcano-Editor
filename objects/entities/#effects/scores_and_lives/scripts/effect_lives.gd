extends "./effect_scores.gd"


func set_shown_texts(amount: int) -> void:
	text = str(amount if amount >= 0 else abs(amount)) + "UP"
	if amount < 0:
		self_modulate = Color.ORANGE_RED
