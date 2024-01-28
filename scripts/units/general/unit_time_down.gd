extends CanvasLayer

signal time_count_down(amount: int) ## Emitted when the timer counts down.
signal time_count_up(amount: int) ## Emitted when the timer counts up.
signal time_warning ## Emitted when not-enough-time warning is triggered.
signal time_over ## Emitted when the timer is up.

@export_category("Unit Time Down")
## Rest time that the character have to complete the level.
@export_range(0, 99999, 1, "suffix:ut") var rest_time: int = 360:
	set = set_rest_time
@export_group("Unit Ticks", "unit_tick_")
## Unit tick of the timer down.
@export_range(0, 86400, 0.001, "suffix:s") var unit_tick: float = 0.5
## Unit ticks to count down.
## [br]
## [b]Note:[/b] The value can be minus, which means that the timer will count [u]up[/u] rather than [i]down[/i].
@export_range(-99999, 99999, 1, "suffix:ut") var unit_tick_down: int = 1
@export_group("Warning", "warning_")
@export_range(0, 99999, 1, "suffix:ut") var warning_line: int = 100
@export_group("Summary", "sum_")
@export_subgroup("Unit Ticks", "sum_unit_tick_")
## [member unit_tick] during the summary.
@export_range(0, 86400, 0.001, "suffix:ut") var sum_unit_tick: float = 0.05
## [member unit_tick_down] during the summary.
@export_range(-99999, 99999, 1, "suffix:ut") var sum_unit_tick_down: int = 15
## Scores that can be gained by the character, per unit tick during the summary.
@export_range(0, 99999, 1, "suffix:point") var sum_scores_per_ut: int = 10
@export_group("Sounds", "sound_")
@export var sound_time_warning: AudioStream = preload("res://assets/sounds/timer_warning.wav")
@export var sound_summarizing: AudioStream = preload("res://assets/sounds/timer_scoring.wav")

var _has_warned: bool # Has the warning been triggered
var _is_sum: bool # Is summarizing

@onready var time: Label = $Frame/Time
@onready var time_count: Label = $Frame/TimeCount
@onready var animation: AnimationPlayer = $Animation
@onready var count_down: Timer = $CountDown
@onready var time_up: Label = $Frame/TimeUp


func _ready() -> void:
	rest_time = rest_time # Triggers the setter to initialize the display of `time_count`
	
	Events.EventCharacter.get_signals().all_characters_dead.connect(stop_time_down)
	Events.EventTimeDown.get_signals().time_down_paused.connect(pause_time_down)
	Events.EventTimeDown.get_signals().time_down_resume.connect(start_time_down)


#region == Timer Controls ==
## Makes the timer start counting down.[br]
## If the timer is paused, this call will resume it rather than restart it.
func start_time_down() -> void:
	if count_down.paused:
		count_down.wait_time = unit_tick
		count_down.paused = false
	else:
		count_down.start(unit_tick)

## Stops the timer from counting down.[br]
## [br]
## [b]Note:[/b] Once this call is done, the timer will stop counting down and the rest ticks to trigger the counting down will be discarded.
func stop_time_down() -> void:
	count_down.stop()

## Pauses the timer from continuing counting down.[br]
## [br]
## [b]Note:[/b] Similar to [method stop_time_down], but the rest ticks will remain.
func pause_time_down() -> void:
	count_down.paused = true
#endregion


func _on_count_down_timeout() -> void:
	rest_time -= sum_unit_tick_down if _is_sum else unit_tick_down


#region == Setgets ==
func set_rest_time(value: int) -> void:
	var delta: int = value - rest_time # Delta
	rest_time = value
	
	if !is_node_ready():
		return
	
	time_count.text = str(rest_time)
	
	# Count down or up
	if delta < 0:
		time_count_down.emit(delta)
	elif delta > 0:
		time_count_up.emit(delta)
	
	# Time warning
	if _has_warned && rest_time >= warning_line:
		_has_warned = false
		animation.play(&"RESET")
	if !_has_warned && rest_time < warning_line:
		_has_warned = true
		animation.play(&"warning")
		Sound.play_1d(sound_time_warning, self)
	
	# Time up
	if rest_time <= 0:
		time_up.visible = true
		var a: float = time_up.modulate.a
		var tw: Tween = time_up.create_tween()
		tw.tween_interval(2)
		tw.tween_property(time_up, ^"modulate:a", 0, 1)
		tw.tween_callback(
			func() -> void:
				time_up.visible = false
				time_up.modulate.a = a
		)
		
		stop_time_down()
		
		time_over.emit()
#endregion
