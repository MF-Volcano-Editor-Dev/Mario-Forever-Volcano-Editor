class_name EnemyStompProcess2D extends Instantiater2D

## Used together with [EnemyStompable] to provide instances creation for it.[br]
## [br]
## This component will instantiate objects based on [member root]. When a character stomps on
## [br]
## [b]Note:[/b] This works only when [signal EnemyStompable.on_stomp_succeeded] is connected to [method stomp_process].

signal stomp_processed ## Emitted when the stomp is processed.

## Jumping speed of the character stomping onto the enemy without the jumping key being held.
@export_range(0, 1, 0.001, "or_greater", "hide_slider", "suffix:px/s") var stomp_jumping_speed_min: float = 400
## Jumping speed of the character stomping onto the enemy with the jumping key being held.
@export_range(0, 1, 0.001, "or_greater", "hide_slider", "suffix:px/s") var stomp_jumping_speed_max: float = 600


## Called to process stomp and instantiate relevant objects.[br]
## [br]
## [b]Note:[/b] Please connect [signal EnemyStompable.on_stomp_succeeded] to this call.
func stomp_process(body: PhysicsBody2D) -> void:
	if !is_instance_valid(body):
		return
	if body is Character:
		var jumping_speed: float = stomp_jumping_speed_max if body.get_input_pressed(&"jump") else stomp_jumping_speed_min
		body.jump(jumping_speed)
	
	instantiate_all()
	
	stomp_processed.emit()
