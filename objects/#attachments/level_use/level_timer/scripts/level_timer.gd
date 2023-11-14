extends CanvasLayer

## Emitted when the timer decreases
signal timer_down(count: int)

## Emitted when the timer increases
signal timer_up(count: int)

## Emitted when the timer is up
signal timer_over

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

var _scoring_count: int
var _scoring: bool
var _has_warned: bool

@onready var current_level: Level = get_tree().current_scene
@onready var interval: Timer = $Interval
@onready var times: Label = $Frame/Container/Times
@onready var time_up: Label = $Frame/TimeUp
@onready var animation_player: AnimationPlayer = $AnimationPlayer


func _ready() -> void:
	# Process of all death of players
	EventsManager.signals.players_all_dead.connect(
		func() -> void:
			interval.paused = true
			
			if current_level:
				current_level.stop_finishing_music()
	)
	
	# Set timer down unit
	interval.wait_time = time_change_unit_tick
	interval.timeout.connect(_time_down)
	
	# Level finishing
	# Add the timer into await list after finish of current level
	# to block the level from fast finishing without scoring
	if current_level:
		current_level.add_object_to_wait_finish(self)
		
		EventsManager.signals.level_finished.connect(
			func() -> void:
				interval.paused = true
				_scoring = true
				
				await current_level.stage_to_be_finished
				
				interval.wait_time = time_down_unit_tick_scoring
				interval.paused = false
		)
	
	# Update display of timer
	rest_time = rest_time


#region Timer Managements
func _time_down() -> void:
	rest_time -= time_down_unit_scoring if _scoring else time_change_unit * time_changing_mode


func _time_warning() -> void:
	if _scoring:
		return
	
	if _has_warned:
		return
	_has_warned = true
	
	if sound_warning:
		Sound.play_sound(self, sound_warning)
	
	animation_player.play(&"warning")
	await animation_player.animation_finished
	animation_player.play(&"RESET")


func _time_scoring(amount: int) -> void:
	# Sound
	_scoring_count += 1
	if _scoring_count > 3:
		_scoring_count = 0
		Sound.play_sound(self, sound_scoring)
	
	Data.add_scores(amount * time_unit_scores)
#endregion


#region Setters & Getters
func set_rest_time(value: int) -> void:
	var to := clampi(value, 0, 86400)
	
	if !is_node_ready():
		await ready
	
	# Decreasing
	if to < rest_time:
		timer_down.emit(to)
		# Time scoring
		if _scoring:
			_time_scoring(rest_time - to)
		# Time warning
		else:
			if to <= warning_time && warning_disabled:
				_time_warning()
			# Time's up
			if to == 0:
				time_up.visible = true
				timer_over.emit()
	# Increasing
	elif to > rest_time:
		timer_up.emit(to)
		# Reset warning state
		if _has_warned && to > warning_time:
			_has_warned = false
	
	# Update timer and its display
	rest_time = to
	times.text = str(rest_time)
	
	# Remove the timer from blocking listif scoring and the timer is zero
	if _scoring && rest_time == 0:
		interval.stop()
		
		await get_tree().create_timer(1).timeout
		
		if current_level:
			current_level.remove_object_to_wait_finish(self)
#endregion
