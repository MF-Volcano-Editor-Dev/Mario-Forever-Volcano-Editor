@icon("res://icons/enemy_touch_stomp.svg")
class_name EnemyTouchStomp extends EnemyTouch

signal stomped_by_character ## Emitted when the enemy is stomped by the character

@export_category("Enemy Touch")
@export_group("Stomping")
## If [code]true[/code], the enemy will not hurt the character
@export var harmless: bool
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
@export_range(0, 45, 0.001, "degrees") var stomping_tolerance_angle: float = 45
@export_subgroup("For Character")
## Minimum of jumping speed when the character stomps onto the enemy without the player holding jumping key
@export_range(0, 1, 0.001, "or_greater", "hide_slider", "suffix:px/s") var stomping_jumping_speed_min: float = 450
## Minimum of jumping speed when the character stomps onto the enemy with the player holding jumping key
@export_range(0, 1, 0.001, "or_greater", "hide_slider", "suffix:px/s") var stomping_jumping_speed_max: float = 700

var _delay: SceneTreeTimer


func _touches_character(character: CharacterEntity2D) -> void:
	if _delay:
		return
	
	var center := (_area.global_position + offset).rotated(_area.global_rotation)
	var dir := character.global_position.direction_to(center)
	var dot := dir.dot(down_direction.rotated(_area.global_rotation))
	
	if dot >= cos(deg_to_rad(stomping_tolerance_angle)):
		stomped_by_character.emit()
		character.jump(stomping_jumping_speed_max if character.get_flagger().is_flag(&"is_jumping") else stomping_jumping_speed_min)
		_delay = get_tree().create_timer(0.08, false)
		_delay.timeout.connect(
			func() -> void:
				_delay = null
		)
	else:
		hurt_character.emit()
		if !harmless:
			character.damaged(hurt_tags)
