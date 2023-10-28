class_name CameraPlayer2D extends Camera2D

## A [Camera2D] used to focus on the players
##
##


func _process(_delta: float) -> void:
	# Delayed for one process frame to make sure the camera
	# focus on the players' average global position accurately
	await get_tree().process_frame
	
	var cgpos: Vector2 = PlayersManager.get_average_global_position(self)
	if cgpos == Vector2.INF:
		return
	
	global_position = cgpos
