extends Node2D

## Emitted when the player death is started
signal player_death_started

## Emitted when the player death is finished
signal player_death_finished

@export_category("Player Death")
@export_group("Physics")
@export_range(-1, 1, 0.001, "or_less", "or_greater", "hide_slider", "suffix:px/s") var speed_y: float = -600
@export_range(0, 1, 0.001, "or_greater", "hide_slider", "suffix:px/s²") var gravity: float = 1250
@export_range(0, 1, 0.001, "or_greater", "hide_slider", "suffix:px/s") var max_falling_speed: float = 500
@export_group("General")
@export_range(0, 12, 0.01, "suffix:s") var emission_await: float = 4
@export_group("Sound", "sound_")
@export var sound_death: AudioStream = preload("res://assets/sounds/death.ogg")

var _tw: Tween
var _fall_rot: bool


@onready var sprite: Sprite2D = $Sprite2D


func _ready() -> void:
	player_death_started.connect(EventsManager.player_all_death_detect)
	player_death_finished.connect(EventsManager.player_all_death_process)
	
	# Await for one process frame to make the character
	# body freed and unregistered so that some methods
	# can work as expected
	await get_tree().process_frame
	
	player_death_started.emit()
	
	Sound.play_sound(self, sound_death)
	
	set_process(false)
	await get_tree().create_timer(0.5, false).timeout
	set_process(true)
	
	await get_tree().create_timer(emission_await, false).timeout
	player_death_finished.emit()
	queue_free()


func _process(delta: float) -> void:
	speed_y += gravity * delta
	if speed_y > max_falling_speed:
		speed_y = max_falling_speed
	move_local_y(speed_y * delta)
	
	if !_fall_rot && speed_y > 0:
		_fall_rot = true
		_fall_rotate()


func _fall_rotate() -> void:
	var r := global_rotation
	_tw = create_tween().set_trans(Tween.TRANS_SINE)
	_tw.tween_property(sprite, ^"global_rotation", r + PI, 0.2)
