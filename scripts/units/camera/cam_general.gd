class_name GeneralCamera2D extends Camera2D


func _physics_process(delta: float) -> void:
	if !is_current():
		return
	_focus.call_deferred()


func _focus() -> void:
	global_position = Character.Getter.get_average_global_position(get_tree(), global_position)
