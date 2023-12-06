extends Node2D

## Base class of dead characters
##
##

signal character_death_started ## Emitted when the character's death is started
signal character_death_finished ## Emitted when the character's death is finished

@export_category("Character Death")
@export_group("Physics")
@export_range(-1, 1, 0.001, "or_less", "or_greater", "hide_slider", "suffix:px/s") var speed_y: float = -600
@export_range(0, 1, 0.001, "or_greater", "hide_slider", "suffix:px/s²") var gravity: float = 1250
@export_range(0, 1, 0.001, "or_greater", "hide_slider", "suffix:px/s") var max_falling_speed: float = 500
@export_group("General")
@export_range(0, 12, 0.01, "suffix:s") var duration: float = 4
@export_group("Sound", "sound_")
@export var sound_death: AudioStream = preload("res://assets/sounds/death.ogg")

var _game_events := Events.get_game_events()
var _tw: Tween # Tween ref

var _fall_rot: bool

@onready var sprite: Sprite2D = $Sprite2D

func _ready() -> void:
	var tree := get_tree()
	
	# Await for one process frame to make the character
	# body freed and unregistered so that some methods
	# can work as expected
	await tree.process_frame
	var cached_players := CharactersManager2D.get_characters_getter().get_characters()
	
	Sound.play_sound(self, sound_death)
	_game_events.player_all_death_detect()
	character_death_started.emit()
	
	set_process(false)
	await tree.create_timer(0.5, false).timeout
	set_process(true)
	
	await tree.create_timer(duration, false).timeout
	_game_events.player_all_death_process(cached_players)
	character_death_finished.emit()
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
