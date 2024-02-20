extends VisibleOnScreenNotifier2D


func _on_screen_exited() -> void:
	print("I'm leaving screen!")


func _on_screen_entered() -> void:
	print("I'm entering screen!")
