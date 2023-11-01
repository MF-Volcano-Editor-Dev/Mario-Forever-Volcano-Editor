extends Component

signal killing_succeeded
signal killing_failed

@export_category("Enemy Body Hazzard")
@export_group("Detection")
@export var disabled: bool
@export_group("Returns")
@export var tags: Dictionary
@export_group("Delay")
@export_range(0, 20, 0.001, "suffix:s") var detection_delay: float = 0.08

var _delay: SceneTreeTimer


func _detect_body(_pre_offset: Vector2 = Vector2.ZERO) -> Dictionary:
	var result: Dictionary = {}
	
	if disabled || _delay || !root is Node2D:
		return result
	
	_delay = get_tree().create_timer(detection_delay, false)
	
	result = {
		success = false,
		enemy_body = self,
		tags = self.tags
	}
	
	_emit_signal.call_deferred(result.success)
	_delay.timeout.connect(
		func() -> void: 
			_delay = null
	)
	
	return result


func _emit_signal(success: bool) -> void:
	if success:
		killing_succeeded.emit()
	else:
		killing_failed.emit()

