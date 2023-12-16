@icon("res://icons/enemy_touch_stomp.svg")
class_name EnemyTouchStomp extends EnemyTouch

signal stomped ## Emitted when the enemy is stomped by a stomper

@export_category("Enemy Touch")
@export_group("Stomping")
## If [code]true[/code], the body will not be stompable
@export var disable_stompability: bool
## Down direction of the enemy, used to detect whether the character's touching the enemy
## is able to be regarded as stomping, or simply, touching.
@export var down_direction: Vector2 = Vector2.DOWN:
	set(value):
		if down_direction:
			down_direction = value.normalized()
## Offset of the detection center
@export var offset: Vector2 = Vector2.DOWN
## Determines how wide the stomping directions will be. The directions out of this range
## will be regarded as simply touching.
@export_range(0, 75, 0.001, "degrees") var stomping_tolerance_angle: float = 75
## Defines how long will be delayed after the previous stomp onto the enemy
@export_range(0, 2, 0.001, "suffix:s") var delay_times: float = 0.08
@export_subgroup("For Character")
## Minimum of jumping speed when the character stomps onto the enemy without the player holding jumping key
@export_range(0, 1, 0.001, "or_greater", "hide_slider", "suffix:px/s") var stomping_jumping_speed_min: float = 450
## Minimum of jumping speed when the character stomps onto the enemy with the player holding jumping key
@export_range(0, 1, 0.001, "or_greater", "hide_slider", "suffix:px/s") var stomping_jumping_speed_max: float = 700

var _delay: SceneTreeTimer


func _touches_entity_area(entity_area: Area2D) -> void:
	if _delay:
		return
	
	var on_stomped: bool = false
	var character := entity_area.get_parent() as CharacterEntity2D
	if !disable_stompability: 
		# If disable_stompability is true, then on_stomped keeps false
		var center := (_area.global_position + offset).rotated(_area.global_rotation)
		var dir := entity_area.global_position.direction_to(center + character.global_velocity * get_process_delta_time() if character && character.is_falling() else Vector2.ZERO)
		var dot := dir.dot(down_direction.rotated(_area.global_rotation))
		
		if dot >= cos(deg_to_rad(stomping_tolerance_angle)):
			on_stomped = true
			stomped.emit()
			# Delay for stomping
			_delay = get_tree().create_timer(delay_times, false)
			_delay.timeout.connect(
				func() -> void:
					_delay = null
			)
			# Character's reaction
			if character:
				character.jump(stomping_jumping_speed_max if character.get_flagger().is_flag(&"is_jumping") else stomping_jumping_speed_min)
	if !on_stomped && character: # Character's getting damage
		if harmless:
			touched_character_friendly.emit(character)
		else:
			hurt_character.emit()
			character.damaged(hurt_tags)
