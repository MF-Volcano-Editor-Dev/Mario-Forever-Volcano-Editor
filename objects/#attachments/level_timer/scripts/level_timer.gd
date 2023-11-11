extends CanvasLayer

## Emitted when the timer decreases
signal timer_down(count: int)

## Emitted when the timer increases
signal timer_up(count: int)

## Emitted when the timer is up
signal timer_over

@export_category("Level Timer")
## Rest time of the level
@export_range(0, 86400, 1, "suffix:ut") var rest_time: int = 360:
	set = set_rest_time
## Time that makes the system warning
@export_range(0, 86400, 1, "suffix:ut") var warning_time: int = 100
## By how many units will each count down decrease
@export_range(0, 100, 1, "suffix:ut") var time_down_unit: int = 1
## By how many seconds will each count down pause [br]
## [b]Note:[/b] This is a unit tick of timer changes, or "ut" in short
@export_range(0, 3600, 0.01, "suffix:s") var time_down_unit_tick: float = 0.5
@export_group("Sounds")
@export var sound_warning: AudioStream = preload("res://assets/sounds/timer_warning.wav")
@export var sound_scoring: AudioStream = preload("res://assets/sounds/timer_scoring.wav")

var _has_warned: bool

@onready var interval: Timer = $Interval
@onready var times: Label = $Frame/Container/Times
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var sound: AudioStreamPlayer = $Sound


func _ready() -> void:
	# Connect signal
	EventsManager.signals.players_all_dead.connect(
		func() -> void:
			interval.paused = true
	)
	
	# Add a thing to do in todo list after finish of current level
	var crl := get_tree().current_scene
	if crl is Level:
		crl.add_object_to_wait_finish(self)
	
	interval.wait_time = time_down_unit_tick
	interval.timeout.connect(_time_down)
	
	_update_rest_time_display()
	
	if rest_time <= warning_time:
		time_warning()


func time_warning() -> void:
	if _has_warned:
		return
	_has_warned = true
	
	if sound_warning:
		sound.stream = sound_warning
		sound.play()
	
	animation_player.play(&"warning")
	await animation_player.animation_finished
	animation_player.play(&"RESET")


func _time_down() -> void:
	rest_time -= time_down_unit


func _update_rest_time_display() -> void:
	times.text = str(rest_time)


#region Setters & Getters
func set_rest_time(value: int) -> void:
	# Decreasing
	if value < rest_time:
		timer_down.emit(value)
		# Time Warning
		if value <= warning_time:
			time_warning()
		# Time's up
		if value == 0:
			timer_over.emit()
	# Increasing
	elif value > rest_time:
		timer_up.emit(value)
		# Reset warning state
		if _has_warned && value > warning_time:
			_has_warned = false
	
	rest_time = clampi(value, 0, 86400)
	
	# Update timer display
	if times:
		_update_rest_time_display()
#endregion
