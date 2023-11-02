extends Component

## Emitted when the body touches the stomper
signal touched_stomper(body: Node2D)

@export_category("Enemy Body")
@export_group("Detection")
@export var disabled: bool
@export_group("Returns")
@export var tags: Dictionary
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
		success = false,
		enemy_body = self,
		tags = self.tags
	}
	
	touched_stomper.emit(body)
	
	return result

