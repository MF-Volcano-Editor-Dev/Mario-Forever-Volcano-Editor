class_name CameraPlayer2D extends Camera2D

## A [Camera2D] used to focus on the players
##
##


func _process(_delta: float) -> void:
	await get_tree().process_frame
	global_position = PlayersManager.get_average_global_position()
