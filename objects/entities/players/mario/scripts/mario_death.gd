extends Node2D

## Emitted when the player death is started
signal player_death_started

## Emitted when the player death is finished
signal player_death_finished

@export_category("Player Death")
@export_group("Physics")
@export_range(0, 1, 0.001, "or_greater", "hide_slider", "suffix:px/s") var initial_velocity_y: float = 600
@export_range(0, 1, 0.001, "or_greater", "hide_slider", "suffix:px/s²") var gravity: float = 1250
@export_range(0, 1, 0.001, "or_greater", "hide_slider", "suffix:px/s") var max_falling_speed: float = 500
@export_group("General")
@export_range(0, 12, 0.01, "suffix:s") var emission_await: float = 4
@export_group("Sound", "sound_")
@export var sound_death: AudioStream = preload("res://assets/sounds/death.ogg")

var _tw: Tween
var _fall_rot: bool
var _velocity: Vector2

@onready var sprite: Sprite2D = $Sprite2D


func _ready() -> void:
	player_death_started.connect(EventsManager.player_all_death_detect)
	player_death_finished.connect(EventsManager.player_all_death_process.bind(get_tree()))
	
	# Await for one process frame to make the character
	# body freed and unregistered so that some methods
	# can work as expected
	await get_tree().process_frame
	
	player_death_started.emit()
	
	Sound.play_sound(self, sound_death)
	
	set_process(false)
	await get_tree().create_timer(0.5).timeout
	set_process(true)
	
	_velocity.y = -initial_velocity_y
	
	await get_tree().create_timer(emission_await).timeout
	player_death_finished.emit()
	queue_free()


func _process(delta: float) -> void:
	_velocity.y += gravity * delta
	if _velocity.y > max_falling_speed:
		_velocity.y = max_falling_speed
	global_position += _velocity.rotated(global_rotation) * delta
	
	if !_fall_rot && _velocity.y > 0:
		_fall_rot = true
		_fall_rotate()


func _fall_rotate() -> void:
	var r := global_rotation
	_tw = create_tween().set_trans(Tween.TRANS_SINE)
	_tw.tween_property(sprite, ^"global_rotation", r + PI, 0.2)
