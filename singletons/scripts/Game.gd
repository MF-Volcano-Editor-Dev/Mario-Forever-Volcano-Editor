extends Node


func _init() -> void:
	boost_fps(2)
	min_window_size(Vector2i(640, 480))


func boost_fps(base: int) -> void:
	var fps: int = int(DisplayServer.screen_get_refresh_rate())
	if fps < 119:
		Engine.physics_ticks_per_second = fps * base
		Engine.max_physics_steps_per_frame = 8 + floori(0.375 * base)
		print(&"[Engine] \n Boosting FPS for physics... \n Boosting by %sx" % [str(base)])
	else:
		Engine.physics_ticks_per_second = fps
	
	Engine.max_fps = ceili(DisplayServer.screen_get_refresh_rate())


func min_window_size(size: Vector2i) -> void:
	DisplayServer.window_set_min_size(size)
