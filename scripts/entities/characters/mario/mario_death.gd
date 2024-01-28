extends Node2D

@export_category("Mario Death")
@export_range(0, 1, 0.001, "or_greater", "hide_slider", "suffix:px/s") var initial_speed: float = 600
@export_range(0, 1, 0.001, "or_greater", "hide_slider", "suffix:x") var gravity_scale: float = 0.5
@export_range(0, 1, 0.001, "or_greater", "hide_slider", "suffix:px/s") var max_falling_speed: float = 500

var _gravity: Vector2
var _velocity: Vector2
var _has_rotated: bool

var sound_death: AudioStream ## [i]Passed by [method Mario.die][/i]

@onready var _character: Mario = get_parent()
@onready var _sprite: Sprite2D = $Sprite2D


func _process(delta: float) -> void:
	_velocity += _gravity * gravity_scale * ProjectSettings.get_setting("physics/2d/default_gravity", 980.0) * delta
	if _velocity.dot(_gravity) > 0 && _velocity.project(_gravity).length_squared() > max_falling_speed ** 2:
		_velocity = _velocity - _velocity.project(_gravity) + _gravity * max_falling_speed
	
	global_position += _velocity * delta
	
	## Rotate
	if !_has_rotated && _velocity.dot(_gravity) > 0:
		_has_rotated = true
		
		var r: float = _sprite.rotation
		var tw: Tween = create_tween().set_trans(Tween.TRANS_SINE)
		tw.tween_property(_sprite, ^"rotation", r + PI * [-1.0, 1.0].pick_random(), 0.2)


## [i]Called by [method Mario.die].[/i][br]
## Activates the death effect.[br]
## [br]
## [b]Note[/b] Since the moment the call get triggered, the character will be deleted from the RAM, the notification to [Events] in terms of "current game over", which should be triggered after the death effect finishes its process as an effect, should be sent by this object.[br]
## See [Events.EventCharacter] for more details.
func death_effect_start() -> void:
	if _character:
		_gravity = _character.get_gravity_vector().normalized()
	
	var sound: AudioStreamPlayer = Sound.play_1d(sound_death, _character)
	
	set_process(false)
	await get_tree().create_timer(0.5, false).timeout
	set_process(true)
	_velocity = Vector2.UP.rotated(global_rotation) * initial_speed
	
	await sound.finished
	await get_tree().create_timer(1, false).timeout
	# TODO: After-death executions
	Events.EventCharacter.current_game_over(get_tree())
	queue_free()
