@icon("res://icons/level_timer.svg")
class_name LevelTimer extends Classes.HiddenCanvasLayer

signal timer_down(count: int) ## Emitted when the timer decreases
signal timer_up(count: int) ## Emitted when the timer increases
signal timer_over  ## Emitted when the timer is up

@export_category("Level Timer")
@export_group("Timer")
## Rest time of the level
@export_range(0, 86400, 1, "suffix:ut") var rest_time: int = 360:
	set = set_rest_time
@export_subgroup("Counting")
@export_enum("Down: 1", "Up: -1") var time_changing_mode: int = 1
## By how many units will the count changes
@export_range(0, 100, 1, "suffix:ut") var time_change_unit: int = 1
## By how many seconds will each count down pause [br]
## [b]Note:[/b] This is a unit tick of timer changes, or "ut" in short
@export_range(0, 3600, 0.01, "suffix:s") var time_change_unit_tick: float = 0.5
@export_subgroup("Warning")
## If [code]true[/code], the warning system will be disabled
@export var warning_disabled: bool
## Time that makes the system warning
@export_range(0, 86400, 1, "suffix:ut") var warning_time: int = 100
@export_group("Scoring")
## [member time_down_unit] when scoring
@export_range(0, 100, 1, "suffix:ut") var time_down_unit_scoring: int = 15
## [member time_down_unit_tick] when scoring
@export_range(0, 3600, 0.01, "suffix:s") var time_down_unit_tick_scoring: float = 0.01
## Scores that one score can provide when scoring
@export_range(0, 1, 1, "or_greater", "hide_slider", "suffix: score") var time_unit_scores: int = 10
@export_group("Sounds")
@export var sound_warning: AudioStream = preload("res://assets/sounds/timer_warning.wav")
@export var sound_scoring: AudioStream = preload("res://assets/sounds/timer_scoring.wav")

#region == Data ==
var _scoring: bool
var _has_warned: bool
#endregion

#region == References ==
@onready var current_level: Level = get_tree().current_scene
@onready var interval: Timer = $Interval
@onready var text_times: Label = $Frame/Container/Times
@onready var text_time_up: Label = $Frame/TimeUp
@onready var text_animation_player: AnimationPlayer = $AnimationPlayer
#endregion


func _ready() -> void:
	rest_time = rest_time # Initializes the value and trigger set_rest_time()
	interval.start(time_change_unit_tick)
	interval.timeout.connect(_on_rest_time_changed)


func _on_rest_time_changed() -> void:
	rest_time -= time_change_unit * time_changing_mode


#region Timer Managements
func set_rest_time(value: int) -> void:
	var delta := value - rest_time
	if delta < 0:
		timer_down.emit(value)
	else:
		timer_up.emit(value)
	
	rest_time = value
	text_times.text = str(rest_time)
	
	if !_scoring:
		_rest_time_event_not_scoring(rest_time)
	else:
		_rest_time_event_scoring(rest_time)

func _rest_time_event_not_scoring(time: int) -> void:
	_warning(time < warning_time)
	
	if time <= 0:
		interval.stop()

func _rest_time_event_scoring(_time: float) -> void:
	pass
#endregion


func _warning(alert: bool) -> void:
	if !_has_warned && alert:
		_has_warned = true
		Sound.play_sound(self, sound_warning)
		text_animation_player.play(&"warning")
	elif _has_warned && !alert:
		_has_warned = false
