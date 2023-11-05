extends Classes.EnemyBody

## Emitted when the enemy is successfully stompped
signal stomped_successful

## Emitted when the enemy survives from stompping
signal stomped_failed

@export_category("Enemy Body Stompable")
@export_group("Detection")
@export var down_direction: Vector2 = Vector2.DOWN:
	set(value):
		down_direction = value
		if down_direction:
			down_direction = down_direction.normalized()
@export var offset: Vector2 = Vector2(0, -4)
@export_group("Returns")
@export_range(0, 1, 0.001, "or_greater", "hide_slider", "suffix:px/s") var jumping_speed_low: float = 400
@export_range(0, 1, 0.001, "or_greater", "hide_slider", "suffix:px/s") var jumping_speed_high: float = 650


func _detect_body(body: Node2D, pre_offset: Vector2 = Vector2.ZERO) -> Dictionary:
	var result: Dictionary = {}
	
	if disabled || _delay || !root is Node2D:
		return result
	
	_delay = get_tree().create_timer(detection_delay, false)
	_delay.timeout.connect(
		func() -> void: 
			_delay = null
	)
	
	var dtl: Vector2 = (pre_offset + offset).rotated(root.global_rotation)
	result = {
		success = snapped(down_direction.rotated(root.global_rotation).dot(dtl), 0.001) > 0,
		enemy_body = self,
		jumping_speed_low = self.jumping_speed_low,
		jumping_speed_high = self.jumping_speed_high,
		tags = self.tags
	}
	
	touched_stomper.emit(body)
	if result.success:
		stomped_successful.emit()
	else:
		stomped_failed.emit()
	
	return result
