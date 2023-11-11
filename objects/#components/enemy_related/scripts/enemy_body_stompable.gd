extends Classes.EnemyBody

## Emitted when the enemy is successfully stompped
signal stomped_successfully

## Emitted when the enemy survives from stompping
signal stomped_failed

## Emitted when the enemy is stomped to death
signal stomped_to_death

@export_category("Enemy Body Stompable")
@export_group("Detection")
@export var down_direction: Vector2 = Vector2.DOWN:
	set(value):
		down_direction = value
		if down_direction:
			down_direction = down_direction.normalized()
@export var inner_offset: Vector2 = Vector2(0, -1)
@export_group("Returns")
@export_range(0, 1, 0.001, "or_greater", "hide_slider", "suffix:px/s") var jumping_speed_low: float = 400
@export_range(0, 1, 0.001, "or_greater", "hide_slider", "suffix:px/s") var jumping_speed_high: float = 650
@export_group("Sounds", "sound_")
@export var sound_player: Sound2D
@export var sound_stomped: AudioStream = preload("res://assets/sounds/stomp.wav")


func _detect_body(body: Node2D, global_offset: Vector2 = Vector2.ZERO) -> Dictionary:
	var result: Dictionary = {}
	
	if disabled || _delay || !root is Node2D:
		return result
	
	_delay = get_tree().create_timer(detection_delay, false)
	_delay.timeout.connect(
		func() -> void: 
			_delay = null
	)
	
	var dtl: Vector2 = global_offset + inner_offset.rotated(root.global_rotation)
	result = {
		stomped = snapped(down_direction.rotated(root.global_rotation).dot(dtl), 0.001) > 0,
		enemy_body = self,
		jumping_speed_low = self.jumping_speed_low,
		jumping_speed_high = self.jumping_speed_high,
	}
	
	touched_body.emit(body)
	
	# Stomping process
	if result.stomped:
		if sound_player:
			sound_player.play_sound(sound_stomped, get_tree().current_scene)
		
		stomped_successfully.emit()
		
		sub_health(1)
		if health <= 0:
			stomped_to_death.emit()
	
	else:
		stomped_failed.emit()
	
	return result
