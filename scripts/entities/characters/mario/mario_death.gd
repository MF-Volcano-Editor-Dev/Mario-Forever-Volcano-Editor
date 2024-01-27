extends Node2D

@export_category("Mario Death")
@export_range(0, 1, 0.001, "or_greater", "hide_slider", "suffix:px/s") var initial_speed: float = 600
@export_range(0, 1, 0.001, "or_greater", "hide_slider", "suffix:x") var gravity_scale: float = 0.5
@export_range(0, 1, 0.001, "or_greater", "hide_slider", "suffix:px/s") var max_falling_speed: float = 500

var _velocity: Vector2
var _has_rotated: bool

var sound_death: AudioStream ## [i]Passed by [method Mario.die][/i]

@onready var _character: Mario = get_parent()
@onready var _sprite: Sprite2D = $Sprite2D


func _process(delta: float) -> void:
	var g: Vector2 = Vector2.DOWN.rotated(global_rotation)
	
	_velocity += g * gravity_scale * ProjectSettings.get_setting("physics/2d/default_gravity", 980.0) * delta
	if _velocity.dot(g) > 0 && _velocity.project(g).length_squared() > max_falling_speed ** 2:
		_velocity = _velocity - _velocity.project(g) + g * max_falling_speed
	
	global_position += _velocity * delta
	
	## Rotate
	if !_has_rotated && _velocity.dot(g) > 0:
		_has_rotated = true
		
		var r: float = _sprite.rotation
		var tw: Tween = create_tween().set_trans(Tween.TRANS_SINE)
		tw.tween_property(_sprite, ^"rotation", r + PI * [-1.0, 1.0].pick_random(), 0.2)


## [i]Called by [method Mario.die].[/i] Activates the death effect.
func death_effect_start() -> void:
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
