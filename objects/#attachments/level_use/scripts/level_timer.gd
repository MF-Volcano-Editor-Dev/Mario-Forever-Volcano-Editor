@icon("res://icons/level_timer.svg")
class_name LevelTimer extends Classes.HiddenCanvasLayer

signal timer_down(count: int) ## Emitted when the timer decreases
signal timer_up(count: int) ## Emitted when the timer increases
signal timer_over  ## Emitted when the timer is up
signal timer_over_scoring ## Emitted when the timer is up in scoring mode

@export_category("Level Timer")
@export_group("Component Links", "path_")
@export_node_path("Node") var path_level_completion: NodePath = ^"../LevelCompletion"
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
var _scoring_sound_count_delay: int
var _has_warned: bool
#endregion

#region == References ==
@onready var level_completion := get_node_or_null(path_level_completion) as LevelCompletion
@onready var interval: Timer = $Interval
@onready var text_times: Label = $Frame/Container/Times
@onready var text_time_up: Label = $Frame/TimeUp
@onready var text_animation_player: AnimationPlayer = $AnimationPlayer
#endregion


func _ready() -> void:
	rest_time = rest_time # Initializes the value and trigger set_rest_time()
	interval.start(time_change_unit_tick)
	interval.timeout.connect(_on_rest_time_changed)
	
	EventsManager.signals.level_to_be_completed.connect(
		# After the completion music is over
		func(state: int) -> void:
			if state != 0: # Check if the state is just after finishment of the music of completion (state: 0)
				return
			if time_changing_mode > 0: # Down-counting mode -> scoring
				_scoring = true
				interval.paused = false # Resume the timer
				interval.start(time_down_unit_tick_scoring) # Counting down ticks -> time_down_unit_tick_scoring
			else: # Up-counting mode -> skips scoring
				timer_over_scoring.emit()
	)
	EventsManager.signals.level_completed.connect(
		# Level's completion, when the finishing music gets playing
		func() -> void:
			interval.paused = true # Pauses the timer first
			if !level_completion:
				return
			level_completion.add_object_to_wait_finish(self) # Blocks the completion
			await timer_over_scoring # Until the scoring is end
			await get_tree().create_timer(1, false).timeout # And delay for 1 second
			level_completion.remove_object_to_wait_finish(self) # Resumes the completion
	)
	EventsManager.signals.level_completion_stopped.connect(
		# Level's completion is stopped
		func() -> void:
			_scoring = false # Cancels scoring
			start() # Resume counting
	)
	EventsManager.signals.players_all_dead.connect(stop) # Stops when all characters are dead


#region == Time down controls ==
## Starts or resumes the timer's counting.
func start() -> void:
	if interval.paused:
		interval.paused = false
	if interval.is_stopped():
		interval.start(time_change_unit_tick)

## Stops the timer's counting.
func stop() -> void:
	interval.stop()

## Pauses the timer's counting. Use [method start] to resume.
func pause() -> void:
	interval.paused = true
#endregion


#region Timer Managements
func set_rest_time(value: int) -> void:
	var clamped := clampi(value, 0, 86400) # Value clamped within correct range
	var delta := clamped - rest_time
	if delta < 0:
		timer_down.emit(clamped)
	else:
		timer_up.emit(clamped)
	
	rest_time = clamped
	text_times.text = str(rest_time)
	
	if _scoring:
		_rest_time_event_scoring(delta)
	else:
		_rest_time_event_not_scoring()

func _rest_time_event_not_scoring() -> void:
	_warning(rest_time < warning_time)
	if rest_time <= 0:
		timer_over.emit()
		interval.stop()

func _rest_time_event_scoring(delta: int) -> void:
	Data.add_scores(time_unit_scores * delta)
	
	_scoring_sound_count_delay += 1
	if _scoring_sound_count_delay > 3:
		_scoring_sound_count_delay = 0
		Sound.play_sound(self, sound_scoring)
	
	if rest_time <= 0:
		timer_over_scoring.emit()
		interval.stop()
#endregion


#region == Time changing and warning ==
func _on_rest_time_changed() -> void:
	if _scoring && time_changing_mode > 0: # Scoring count
		rest_time -= time_down_unit_scoring
	else: # Regular count
		rest_time -= time_change_unit * time_changing_mode

func _warning(alert: bool) -> void:
	if !_has_warned && alert:
		_has_warned = true
		Sound.play_sound(self, sound_warning)
		text_animation_player.play(&"warning")
	elif _has_warned && !alert:
		_has_warned = false
#endregion
