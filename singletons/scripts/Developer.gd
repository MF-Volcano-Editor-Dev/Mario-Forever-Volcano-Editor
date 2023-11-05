extends Node

var _pause_tick: SceneTreeTimer


func _init() -> void:
	process_mode = PROCESS_MODE_ALWAYS


func _input(event: InputEvent) -> void:
	if !_pause_tick && event.is_action_pressed("ui_cancel"):
		get_tree().paused = !get_tree().paused
		_pause_tick = get_tree().create_timer(0.1)
		await _pause_tick.timeout
		_pause_tick = null
