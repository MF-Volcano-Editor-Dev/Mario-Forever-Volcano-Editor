extends Classes.HealthComponent

## Emitted when the body touches the stomper
signal touched_body(body: Node2D)

@export_category("Enemy Body")
@export_group("Delay")
@export_range(0, 20, 0.001, "suffix:s") var detection_delay: float = 0.08

var _delay: SceneTreeTimer


func _detect_body(body: Node2D, _pre_offset: Vector2 = Vector2.ZERO) -> Dictionary:
	var result: Dictionary = {}
	
	if disabled || _delay:
		return result
	
	_delay = get_tree().create_timer(detection_delay, false)
	_delay.timeout.connect(
		func() -> void: 
			_delay = null
	)
	
	result = {
		stomped = false,
		enemy_body = self,
	}
	
	touched_body.emit(body)
	
	return result

