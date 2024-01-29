class_name GeneralCamera2D extends Camera2D

var _shaking: Tween


func _physics_process(delta: float) -> void:
	if !enabled || !is_current():
		return
	_focus.call_deferred()


func _focus() -> void:
	global_position = Character.Getter.get_average_global_position(get_tree(), global_position)


## Shakes the camera.
func shake(max_amplitude: Vector2, times: int, duration: float = 0.03, trans: Tween.TransitionType = Tween.TRANS_SINE) -> void:
	if _shaking:
		return
	
	var ofs: Vector2 = offset
	_shaking = create_tween().set_trans(trans)
	for i in times:
		_shaking.tween_property(self, ^"offset", Vector2(randf_range(-max_amplitude.x, max_amplitude.x), randf_range(-max_amplitude.y, max_amplitude.y)), duration)
	
	await _shaking.finished
	
	_shaking = null
	offset = ofs
